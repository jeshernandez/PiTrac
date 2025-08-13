#!/usr/bin/env bash
set -euo pipefail

# PiTrac Hardened Installation System
# Version 2.0 - With dependency resolution and rollback support

# Ensure we are running under bash
if [ -z "${BASH_VERSION:-}" ]; then
  echo "This script must be run with bash, not sh."
  exit 1
fi

# Paths and configuration
SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
DEP_RESOLVER="${SCRIPT_DIR}/scripts/dep_resolver.sh"
LOCK_FILE="${SCRIPT_DIR}/.pitrac_install.lock"
SESSION_LOG="${SCRIPT_DIR}/.session.log"

# sudo only if needed
if [ "$(id -u)" -eq 0 ]; then SUDO=""; else SUDO="sudo"; fi
export DEBIAN_FRONTEND=noninteractive

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $*" | tee -a "$SESSION_LOG"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*" | tee -a "$SESSION_LOG"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" | tee -a "$SESSION_LOG"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*" | tee -a "$SESSION_LOG"; }

# Initialize session
init_session() {
    echo "# PiTrac hardened installation session - $(date)" > "$SESSION_LOG"
    log_info "Starting PiTrac hardened installation system"
    
    # Check if another installation is running
    if [ -f "$LOCK_FILE" ]; then
        local lock_pid
        lock_pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
        if [ -n "$lock_pid" ] && kill -0 "$lock_pid" 2>/dev/null; then
            log_error "Another installation is running (PID: $lock_pid)"
            exit 1
        else
            log_warn "Stale lock file found, removing"
            rm -f "$LOCK_FILE"
        fi
    fi
    
    # Create lock file
    echo $$ > "$LOCK_FILE"
    trap cleanup_session EXIT
}

cleanup_session() {
    log_info "Cleaning up session"
    rm -f "$LOCK_FILE"
}

# Enhanced package management
apt_ensure() {
  local need=()
  for p in "$@"; do 
    if ! dpkg -s "$p" >/dev/null 2>&1; then
      need+=("$p")
    fi
  done
  
  if [ "${#need[@]}" -gt 0 ]; then
    log_info "Installing system packages: ${need[*]}"
    
    # Update package lists if they're old
    local last_update
    if [ -f /var/lib/apt/periodic/update-success-stamp ]; then
      last_update=$(stat -c %Y /var/lib/apt/periodic/update-success-stamp)
    else
      last_update=0
    fi
    
    local current_time
    current_time=$(date +%s)
    
    # Update if stamp is older than 1 hour
    if [ $((current_time - last_update)) -gt 3600 ]; then
      log_info "Updating package lists..."
      $SUDO apt-get update
    fi
    
    # Install packages with retry logic
    local attempt=1
    local max_attempts=3
    
    while [ $attempt -le $max_attempts ]; do
      log_info "Installing packages (attempt $attempt/$max_attempts)..."
      
      if $SUDO apt-get install -y --no-install-recommends "${need[@]}"; then
        log_success "System packages installed successfully"
        return 0
      else
        log_warn "Package installation failed, attempt $attempt/$max_attempts"
        if [ $attempt -lt $max_attempts ]; then
          log_info "Retrying in 5 seconds..."
          sleep 5
          $SUDO apt-get update
        fi
        ((attempt++))
      fi
    done
    
    log_error "Failed to install system packages after $max_attempts attempts"
    return 1
  fi
}

# Install prerequisites
install_prerequisites() {
    log_info "Installing prerequisites..."
    
    # Essential packages for the system to function
    apt_ensure dialog curl wget ca-certificates
    
    # Install vim if requested
    if ! command -v vim >/dev/null 2>&1; then
        log_info "Installing vim..."
        apt_ensure vim
    fi
    
    # Copy vimrc if present
    if [ -f "${SCRIPT_DIR}/assets/vimrc" ]; then
        log_info "Copying vimrc to ~/.vimrc"
        cp "${SCRIPT_DIR}/assets/vimrc" ~/.vimrc
    fi
    
    # Make dependency resolver executable
    chmod +x "$DEP_RESOLVER" 2>/dev/null || true
    
    # Verify dependency resolver works
    if ! "$DEP_RESOLVER" list >/dev/null 2>&1; then
        log_error "Dependency resolver is not working properly"
        exit 1
    fi
    
    log_success "Prerequisites installed"
}

# Enhanced connectivity check
check_internet_connectivity() {
    log_info "Checking internet connectivity..."
    
    # First try ping if available
    if command -v ping >/dev/null 2>&1; then
        if ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1; then
            log_success "Internet connectivity verified (ICMP)"
            return 0
        fi
    fi
    
    # Try HTTP connectivity test
    local test_urls=(
        "http://connectivitycheck.gstatic.com/generate_204"
        "http://clients3.google.com/generate_204"
        "http://www.msftconnecttest.com/connecttest.txt"
    )
    
    for url in "${test_urls[@]}"; do
        if command -v curl >/dev/null 2>&1; then
            if curl -fsS --max-time 5 "$url" >/dev/null 2>&1; then
                log_success "Internet connectivity verified (HTTP)"
                return 0
            fi
        elif command -v wget >/dev/null 2>&1; then
            if wget -q --timeout=5 -O /dev/null "$url" 2>/dev/null; then
                log_success "Internet connectivity verified (HTTP)"
                return 0
            fi
        fi
    done
    
    log_error "Internet connectivity check failed"
    log_error "Please check your network connection and try again"
    exit 1
}

# Enhanced menu system with dependency awareness
show_installation_status() {
    local package="$1"
    if "$DEP_RESOLVER" verify "$package" >/dev/null 2>&1; then
        echo "[INSTALLED]"
    else
        echo "[NOT INSTALLED]"
    fi
}

# Menu configuration
BUILD="6.12.34-1"
VERSION="2.0-hardened"
TITLE="PiTrac Hardened Installer - Raspberry Pi OS >= $BUILD"
HEIGHT=20
WIDTH=70
MENU_HEIGHT=12

# Available packages
declare -A PACKAGES=(
    ["activemq-broker"]="ActiveMQ Broker 6.1.7"
    ["activemq-cpp"]="ActiveMQ C++ CMS"
    ["boost"]="Boost 1.74 Libraries"
    ["opencv"]="OpenCV 4.11.0"
    ["msgpack"]="MessagePack C++"
    ["lgpio"]="LGPIO Library"
    ["libcamera"]="Libcamera & RpiCam Apps"
    ["java"]="Java 17 OpenJDK"
    ["maven"]="Apache Maven"
    ["tomee"]="Apache TomEE 10.1.0"
    ["pitrac-deps"]="PiTrac Dependencies"
)

show_main_menu() {
    while true; do
        local main_options=(
            1 "Install Software"
            2 "Verify Installations"
            3 "System Maintenance"
            4 "View Logs"
            5 "Exit"
        )
        
        local main_choice
        main_choice=$(dialog --clear \
            --title "$TITLE" \
            --ok-label "OK" \
            --cancel-label "Exit" \
            --menu "Version $VERSION" \
            $HEIGHT $WIDTH $MENU_HEIGHT \
            "${main_options[@]}" \
            2>&1 >/dev/tty)
            
        local exit_code=$?
        if [ $exit_code -ne 0 ]; then
            clear
            log_info "Exiting installer"
            exit 0
        fi
        
        case "$main_choice" in
            1) show_install_menu ;;
            2) show_verify_menu ;;
            3) show_maintenance_menu ;;
            4) show_logs_menu ;;
            5) clear; exit 0 ;;
            *) log_error "Invalid selection: $main_choice" ;;
        esac
    done
}

show_install_menu() {
    while true; do
        local install_options=()
        install_options+=(1 "Install ALL Dependencies")
        
        local i=2
        for package in "${!PACKAGES[@]}"; do
            local status
            status=$(show_installation_status "$package")
            install_options+=($i "${PACKAGES[$package]} $status")
            ((i++))
        done
        install_options+=($i "Go Back to Main Menu")
        
        local install_choice
        install_choice=$(dialog --clear \
            --title "PiTrac Installation Menu" \
            --menu "Select what to install:" \
            $HEIGHT $WIDTH $MENU_HEIGHT \
            "${install_options[@]}" \
            2>&1 >/dev/tty)
            
        local exit_code=$?
        if [ $exit_code -ne 0 ] || [ "$install_choice" -eq $i ]; then
            break
        fi
        
        clear
        
        if [ "$install_choice" -eq 1 ]; then
            # Install all dependencies
            dialog --yesno "This will install ALL PiTrac dependencies. This may take a long time. Continue?" 8 60
            if [ $? -eq 0 ]; then
                install_all_dependencies
            fi
        else
            # Install specific package
            local package_index=$((install_choice - 2))
            local packages_array=(${!PACKAGES[@]})
            local selected_package="${packages_array[$package_index]}"
            
            if [ -n "$selected_package" ]; then
                dialog --yesno "Install ${PACKAGES[$selected_package]}?" 7 50
                if [ $? -eq 0 ]; then
                    install_single_package "$selected_package"
                fi
            fi
        fi
        
        echo
        read -rp "Press Enter to continue..."
    done
}

install_all_dependencies() {
    log_info "Installing all PiTrac dependencies..."
    
    # Define the complete dependency chain
    local all_packages=(
        "java" "maven" "boost" "activemq-broker" "activemq-cpp" 
        "msgpack" "lgpio" "opencv" "libcamera" "tomee" "pitrac-deps"
    )
    
    for package in "${all_packages[@]}"; do
        log_info "Installing $package and its dependencies..."
        if ! "$DEP_RESOLVER" install "$package"; then
            log_error "Failed to install $package"
            dialog --msgbox "Installation failed at package: $package\nCheck logs for details." 8 50
            return 1
        fi
    done
    
    log_success "All dependencies installed successfully!"
    dialog --msgbox "All PiTrac dependencies have been installed successfully!" 8 50
}

install_single_package() {
    local package="$1"
    
    log_info "Installing $package..."
    
    if "$DEP_RESOLVER" install "$package"; then
        log_success "$package installed successfully"
        dialog --msgbox "${PACKAGES[$package]} installed successfully!" 8 50
    else
        log_error "Failed to install $package"
        dialog --msgbox "Failed to install ${PACKAGES[$package]}\nCheck logs for details." 8 50
    fi
}

show_verify_menu() {
    local verify_options=()
    local i=1
    
    for package in "${!PACKAGES[@]}"; do
        local status
        status=$(show_installation_status "$package")
        verify_options+=($i "${PACKAGES[$package]} $status")
        ((i++))
    done
    verify_options+=($i "Verify All Packages")
    verify_options+=($(($i + 1)) "Go Back to Main Menu")
    
    local verify_choice
    verify_choice=$(dialog --clear \
        --title "Verification Menu" \
        --menu "Select package to verify:" \
        $HEIGHT $WIDTH $MENU_HEIGHT \
        "${verify_options[@]}" \
        2>&1 >/dev/tty)
        
    local exit_code=$?
    if [ $exit_code -ne 0 ] || [ "$verify_choice" -eq $(($i + 1)) ]; then
        return 0
    fi
    
    clear
    
    if [ "$verify_choice" -eq $i ]; then
        # Verify all packages
        verify_all_packages
    else
        # Verify specific package
        local package_index=$((verify_choice - 1))
        local packages_array=(${!PACKAGES[@]})
        local selected_package="${packages_array[$package_index]}"
        
        if [ -n "$selected_package" ]; then
            verify_single_package "$selected_package"
        fi
    fi
    
    echo
    read -rp "Press Enter to continue..."
}

verify_all_packages() {
    log_info "Verifying all installed packages..."
    
    local all_good=true
    for package in "${!PACKAGES[@]}"; do
        if "$DEP_RESOLVER" verify "$package" >/dev/null 2>&1; then
            log_success "${PACKAGES[$package]}: OK"
        else
            log_error "${PACKAGES[$package]}: FAILED"
            all_good=false
        fi
    done
    
    if $all_good; then
        log_success "All installed packages verified successfully"
    else
        log_warn "Some packages failed verification"
    fi
}

verify_single_package() {
    local package="$1"
    
    log_info "Verifying $package..."
    
    if "$DEP_RESOLVER" verify "$package"; then
        log_success "${PACKAGES[$package]} verified successfully"
    else
        log_error "${PACKAGES[$package]} verification failed"
    fi
}

show_maintenance_menu() {
    local maintenance_options=(
        1 "Update Package Lists"
        2 "Clean Package Cache"
        3 "Show Disk Usage"
        4 "Rollback Last Installation"
        5 "Reset Installation State"
        6 "Go Back to Main Menu"
    )
    
    local maintenance_choice
    maintenance_choice=$(dialog --clear \
        --title "System Maintenance" \
        --menu "Select maintenance task:" \
        $HEIGHT $WIDTH $MENU_HEIGHT \
        "${maintenance_options[@]}" \
        2>&1 >/dev/tty)
        
    local exit_code=$?
    if [ $exit_code -ne 0 ] || [ "$maintenance_choice" -eq 6 ]; then
        return 0
    fi
    
    clear
    
    case "$maintenance_choice" in
        1) 
            log_info "Updating package lists..."
            $SUDO apt-get update
            log_success "Package lists updated"
            ;;
        2)
            log_info "Cleaning package cache..."
            $SUDO apt-get clean
            $SUDO apt-get autoclean
            log_success "Package cache cleaned"
            ;;
        3)
            log_info "Disk usage summary:"
            df -h
            echo
            log_info "Package cache usage:"
            du -sh /var/cache/apt/archives/
            ;;
        4)
            dialog --yesno "This will attempt to rollback the last installation. Continue?" 7 60
            if [ $? -eq 0 ]; then
                "$DEP_RESOLVER" rollback
            fi
            ;;
        5)
            dialog --yesno "This will reset all installation state. You may need to reinstall everything. Continue?" 8 70
            if [ $? -eq 0 ]; then
                rm -f "${SCRIPT_DIR}/scripts/.install.log"
                rm -f "${SCRIPT_DIR}/scripts/.rollback.log"
                log_info "Installation state reset"
            fi
            ;;
    esac
    
    echo
    read -rp "Press Enter to continue..."
}

show_logs_menu() {
    local log_files=(
        "${SESSION_LOG}"
        "${SCRIPT_DIR}/scripts/.install.log"
        "/var/log/apt/history.log"
    )
    
    local log_options=(
        1 "View Current Session Log"
        2 "View Installation Log"
        3 "View APT History"
        4 "View All Logs"
        5 "Go Back to Main Menu"
    )
    
    local log_choice
    log_choice=$(dialog --clear \
        --title "View Logs" \
        --menu "Select log to view:" \
        $HEIGHT $WIDTH $MENU_HEIGHT \
        "${log_options[@]}" \
        2>&1 >/dev/tty)
        
    local exit_code=$?
    if [ $exit_code -ne 0 ] || [ "$log_choice" -eq 5 ]; then
        return 0
    fi
    
    clear
    
    case "$log_choice" in
        1|2|3)
            local log_file="${log_files[$((log_choice - 1))]}"
            if [ -f "$log_file" ]; then
                log_info "Viewing: $log_file"
                less "$log_file"
            else
                log_warn "Log file not found: $log_file"
            fi
            ;;
        4)
            log_info "Viewing all available logs:"
            for log_file in "${log_files[@]}"; do
                if [ -f "$log_file" ]; then
                    echo "=== $log_file ==="
                    tail -n 20 "$log_file"
                    echo
                fi
            done | less
            ;;
    esac
}

# Main
main() {
    # Initialize session
    init_session
    
    # Perform initial checks
    check_internet_connectivity
    install_prerequisites
    
    # Show menu
    show_main_menu
    
    # Cleanup
    clear
    log_success "PiTrac installer session completed"
}

# Handle signals gracefully
trap 'log_error "Installation interrupted"; cleanup_session; exit 1' INT TERM

# Run if called directly
main "$@"
