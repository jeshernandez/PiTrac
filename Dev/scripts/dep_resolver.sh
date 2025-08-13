#!/usr/bin/env bash
# PiTrac Dependency Resolution System
# Provides centralized dependency management with proper ordering and rollback
set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
DEPS_CONFIG="${SCRIPT_DIR}/deps.conf"
INSTALL_LOG="${SCRIPT_DIR}/.install.log"
ROLLBACK_LOG="${SCRIPT_DIR}/.rollback.log"

# Use sudo only if not root
if [ "$(id -u)" -eq 0 ]; then SUDO=""; else SUDO="sudo"; fi
export DEBIAN_FRONTEND=noninteractive

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }

# Initialize logs
init_logs() {
    echo "# PiTrac installation log - $(date)" > "$INSTALL_LOG"
    echo "# PiTrac rollback log - $(date)" > "$ROLLBACK_LOG"
}

# Package management helpers
apt_ensure() {
    local need=()
    for p in "$@"; do 
        dpkg -s "$p" >/dev/null 2>&1 || need+=("$p")
    done
    if [ "${#need[@]}" -gt 0 ]; then
        log_info "Installing system packages: ${need[*]}"
        $SUDO apt-get update
        $SUDO apt-get install -y --no-install-recommends "${need[@]}"
        echo "apt:${need[*]}" >> "$INSTALL_LOG"
    fi
}

# Parse dependency configuration
parse_deps_config() {
    local package="$1"
    if ! grep -q "^${package}:" "$DEPS_CONFIG"; then
        log_error "Package '$package' not found in deps.conf"
        return 1
    fi
    
    local line
    line=$(grep "^${package}:" "$DEPS_CONFIG" | head -n1)
    
    # Split the line: package:deps:detection:script
    IFS=':' read -r pkg_name deps detection script <<< "$line"
    
    echo "PKG_NAME=$pkg_name"
    echo "DEPS=$deps"
    echo "DETECTION=$detection"
    echo "SCRIPT=$script"
}

# Load install script functions - removed broken function extraction
# Detection functions are loaded on-demand in is_package_installed()

# Check if a package is already installed
is_package_installed() {
    local package="$1"
    local config
    config=$(parse_deps_config "$package") || return 1
    
    eval "$config"
    
    case "$DETECTION" in
        "cmd")
            local cmd_name="${SCRIPT##*/}"  # Extract command from script name
            cmd_name="${cmd_name#install_}"
            cmd_name="${cmd_name%.sh}"
            
            case "$cmd_name" in
                "mq_broker") command -v java >/dev/null 2>&1 && [ -d "/opt/apache-activemq" ] ;;
                "tomee") command -v java >/dev/null 2>&1 && [ -d "/opt/tomee" ] ;;
                *) command -v "$cmd_name" >/dev/null 2>&1 ;;
            esac
            ;;
        "pkg-config")
            pkg-config --exists "$PKG_NAME" 2>/dev/null
            ;;
        "file")
            [ -f "$SCRIPT" ]
            ;;
        "function")
            # Load script and call detection function
            local script_path="${SCRIPT_DIR}/${SCRIPT}"
            
            if [ -f "$script_path" ]; then
                # Source the entire script to get all functions
                source "$script_path" 2>/dev/null || true
                
                # Call the detection function
                local func_name=""
                case "$package" in
                    "activemq-broker") func_name="get_activemq_broker_version" ;;
                    "activemq-cpp") func_name="is_activemq_cpp_installed" ;;
                    "msgpack") func_name="have_msgpack" ;;
                    "lgpio") func_name="lgpio_already_installed" ;;
                    "opencv") func_name="is_opencv_installed" ;;
                    "libcamera") func_name="have_libcamera" ;;
                    "tomee") func_name="get_tomee_installed_version" ;;
                    "system-config") func_name="is_system_config_installed" ;;
                    "camera-config") func_name="is_camera_config_installed" ;;
                    "pitrac-environment") func_name="is_pitrac_environment_installed" ;;
                    "network-services") func_name="is_network_services_installed" ;;
                    "dev-environment") func_name="is_dev_environment_installed" ;;
                esac
                
                if [ -n "$func_name" ] && declare -F "$func_name" >/dev/null 2>&1; then
                    "$func_name"
                else
                    log_warn "Detection function '$func_name' not found for $package"
                    return 1
                fi
            else
                log_warn "Script not found: $script_path"
                return 1
            fi
            ;;
        "apt")
            if [ "$DEPS" = "SYSTEM" ]; then
                # For SYSTEM packages, use SCRIPT field for actual package names
                if [ -n "$SCRIPT" ]; then
                    local all_installed=true
                    IFS=',' read -ra PACKAGES <<< "$SCRIPT"
                    for pkg in "${PACKAGES[@]}"; do
                        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
                            all_installed=false
                            break
                        fi
                    done
                    $all_installed
                else
                    dpkg -s "$PKG_NAME" >/dev/null 2>&1
                fi
            else
                # For apt packages with dependencies, check all packages in SCRIPT field
                local all_installed=true
                IFS=',' read -ra PACKAGES <<< "${SCRIPT:-$PKG_NAME}"
                for pkg in "${PACKAGES[@]}"; do
                    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
                        all_installed=false
                        break
                    fi
                done
                $all_installed
            fi
            ;;
        *)
            log_error "Unknown detection method: $DETECTION"
            return 1
            ;;
    esac
}

# Resolve dependencies recursively
resolve_dependencies() {
    local package="$1"
    local -A visited
    local -a install_order
    
    _resolve_recursive() {
        local pkg="$1"
        
        # Skip if already visited
        if [[ -n "${visited[$pkg]:-}" ]]; then
            return 0
        fi
        
        visited[$pkg]=1
        
        # Parse package config
        local config
        config=$(parse_deps_config "$pkg") || return 1
        eval "$config"
        
        # Skip system packages or packages with no dependencies
        if [ "$DEPS" = "SYSTEM" ] || [ -z "$DEPS" ]; then
            install_order+=("$pkg")
            return 0
        fi
        
        # Process dependencies first
        IFS=',' read -ra DEP_ARRAY <<< "$DEPS"
        for dep in "${DEP_ARRAY[@]}"; do
            dep=$(echo "$dep" | xargs)  # trim whitespace
            if [ -n "$dep" ]; then
                _resolve_recursive "$dep"
            fi
        done
        
        install_order+=("$pkg")
    }
    
    _resolve_recursive "$package"
    printf '%s\n' "${install_order[@]}"
}

# Install a single package
install_package() {
    local package="$1"
    
    log_info "Installing package: $package"
    
    if is_package_installed "$package"; then
        log_success "$package already installed, skipping"
        return 0
    fi
    
    local config
    config=$(parse_deps_config "$package") || return 1
    eval "$config"
    
    case "$DETECTION" in
        "apt")
            if [ "$DEPS" = "SYSTEM" ]; then
                # For SYSTEM packages, use SCRIPT field for actual package names
                if [ -n "$SCRIPT" ]; then
                    IFS=',' read -ra PACKAGES <<< "$SCRIPT"
                    apt_ensure "${PACKAGES[@]}"
                else
                    apt_ensure "$PKG_NAME"
                fi
            else
                # Install packages listed in SCRIPT field
                IFS=',' read -ra PACKAGES <<< "$SCRIPT"
                apt_ensure "${PACKAGES[@]}"
            fi
            ;;
        *)
            if [ -n "$SCRIPT" ] && [ -f "${SCRIPT_DIR}/${SCRIPT}" ]; then
                log_info "Running installation script: $SCRIPT"
                # Run with TTY if available, otherwise run normally
                local script_success=false
                if [ -t 0 ] && [ -t 1 ]; then
                    # TTY available - run with TTY access
                    bash "${SCRIPT_DIR}/${SCRIPT}" < /dev/tty && script_success=true
                elif tty -s 2>/dev/null; then
                    # TTY available via tty command
                    bash "${SCRIPT_DIR}/${SCRIPT}" < $(tty) && script_success=true
                else
                    # No TTY - run in non-interactive mode
                    log_warn "No TTY available - running $SCRIPT in non-interactive mode"
                    bash "${SCRIPT_DIR}/${SCRIPT}" --non-interactive && script_success=true
                fi
                
                if $script_success; then
                    echo "script:${SCRIPT}" >> "$INSTALL_LOG"
                    log_success "$package installed successfully"
                else
                    log_error "Failed to install $package"
                    return 1
                fi
            else
                log_error "No installation method found for $package"
                return 1
            fi
            ;;
    esac
}

# Install packages with dependency resolution
install_with_deps() {
    local target_package="$1"
    
    log_info "Resolving dependencies for: $target_package"
    
    local install_order
    mapfile -t install_order < <(resolve_dependencies "$target_package")
    
    log_info "Installation order: ${install_order[*]}"
    
    # Install packages in dependency order
    for package in "${install_order[@]}"; do
        if ! install_package "$package"; then
            log_error "Failed to install $package, aborting"
            return 1
        fi
    done
    
    log_success "All dependencies for $target_package installed successfully"
}

# Rollback installation
rollback() {
    if [ ! -f "$INSTALL_LOG" ]; then
        log_warn "No installation log found, cannot rollback"
        return 0
    fi
    
    log_info "Rolling back installation..."
    
    # Process rollback in reverse order
    tac "$INSTALL_LOG" | while IFS=':' read -r type details; do
        case "$type" in
            "apt")
                log_info "Would remove packages: $details"
                # Uncomment to actually remove packages
                # $SUDO apt-get remove -y $details
                ;;
            "script")
                log_info "Installed by script: $details"
                # Script-based installations would need custom rollback logic
                ;;
        esac
    done
    
    log_info "Rollback completed"
}

# Verify all installations
verify_installation() {
    local package="$1"
    
    log_info "Verifying installation: $package"
    
    local order
    mapfile -t order < <(resolve_dependencies "$package")
    
    local all_good=true
    for pkg in "${order[@]}"; do
        if is_package_installed "$pkg"; then
            log_success "$pkg: OK"
        else
            log_error "$pkg: MISSING"
            all_good=false
        fi
    done
    
    if $all_good; then
        log_success "All components verified successfully"
    else
        log_error "Some components are missing"
        return 1
    fi
}

# Main
main() {
    local action="${1:-install}"
    local package="${2:-}"
    
    # Initialize
    init_logs
    
    case "$action" in
        "install")
            if [ -z "$package" ]; then
                log_error "Usage: $0 install <package>"
                exit 1
            fi
            install_with_deps "$package"
            ;;
        "verify")
            if [ -z "$package" ]; then
                log_error "Usage: $0 verify <package>"
                exit 1
            fi
            verify_installation "$package"
            ;;
        "rollback")
            rollback
            ;;
        "list")
            log_info "Available packages:"
            grep -v '^#' "$DEPS_CONFIG" | cut -d: -f1 | sort
            ;;
        "deps")
            if [ -z "$package" ]; then
                log_error "Usage: $0 deps <package>"
                exit 1
            fi
            resolve_dependencies "$package"
            ;;
        *)
            echo "Usage: $0 {install|verify|rollback|list|deps} [package]"
            echo ""
            echo "Commands:"
            echo "  install <package>  - Install package with dependencies"
            echo "  verify <package>   - Verify package installation"
            echo "  rollback          - Rollback last installation"
            echo "  list              - List available packages"
            echo "  deps <package>    - Show dependency resolution order"
            exit 1
            ;;
    esac
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi