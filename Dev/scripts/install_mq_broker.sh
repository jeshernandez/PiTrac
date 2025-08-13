#!/usr/bin/env bash
set -euo pipefail

# ActiveMQ Broker Installation Script
ACTIVEMQ_VERSION="${ACTIVEMQ_VERSION:-6.1.7}"
INSTALL_DIR="${INSTALL_DIR:-/opt/apache-activemq}"
FILENAME="apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz"
URL="https://www.apache.org/dyn/closer.cgi?filename=/activemq/${ACTIVEMQ_VERSION}/${FILENAME}&action=download"
FORCE="${FORCE:-0}"

# Use sudo only if not already root
if [ "$(id -u)" -eq 0 ]; then SUDO=""; else SUDO="sudo"; fi
export DEBIAN_FRONTEND=noninteractive

# Package management helper
apt_ensure() {
  local pkgs=()
  for p in "$@"; do 
    dpkg -s "$p" >/dev/null 2>&1 || pkgs+=("$p")
  done
  if [ "${#pkgs[@]}" -gt 0 ]; then
    $SUDO apt-get update
    $SUDO apt-get install -y --no-install-recommends "${pkgs[@]}"
  fi
}

get_installed_version() {
  # Try the activemq script
  if [ -x "${INSTALL_DIR}/bin/activemq" ]; then
    local out ver
    out="$("${INSTALL_DIR}/bin/activemq" --version 2>/dev/null || true)"
    ver="$(grep -Eo '[0-9]+(\.[0-9]+)+' <<<"$out" | head -n1 || true)"
    [ -n "$ver" ] && { echo "$ver"; return 0; }
  fi
  # Fallback: try to infer from directory contents/jars (best-effort)
  ver="$(basename "${INSTALL_DIR}" | grep -Eo '[0-9]+(\.[0-9]+)+' || true)"
  [ -n "$ver" ] && { echo "$ver"; return 0; }
  echo ""
  return 1
}

# Check if activemq is installed
get_activemq_broker_version() {
  local ver
  ver="$(get_installed_version)"
  [ -n "$ver" ] && return 0
  return 1
}

# Version comparison helper
version_ge() { 
  dpkg --compare-versions "$1" ge "$2"
}

# Backup existing installation
backup_existing() {
  local ts backup
  ts="$(date +%Y%m%d-%H%M%S)"
  backup="${INSTALL_DIR}.bak.${ts}"
  echo "Backing up existing install to: ${backup}"
  $SUDO mv "$INSTALL_DIR" "$backup"
}

# Pre-installation checks
precheck() {
  if [ -d "$INSTALL_DIR" ]; then
    local cur
    cur="$(get_installed_version || true)"
    if [ -n "$cur" ]; then
      if version_ge "$cur" "$ACTIVEMQ_VERSION"; then
        echo "ActiveMQ ${cur} already installed at ${INSTALL_DIR} (>= ${ACTIVEMQ_VERSION}). Skipping."
        return 0
      else
        if [ "$FORCE" = "1" ]; then
          echo "ActiveMQ ${cur} found (< ${ACTIVEMQ_VERSION}). Will upgrade (FORCE=1)."
          backup_existing
        else
          echo "ActiveMQ ${cur} found at ${INSTALL_DIR}. Set FORCE=1 to upgrade to ${ACTIVEMQ_VERSION}."
          return 0
        fi
      fi
    else
      echo "ActiveMQ present at ${INSTALL_DIR}, but version unknown."
      if [ "$FORCE" = "1" ]; then
        backup_existing
      else
        echo "Set FORCE=1 to overwrite. Aborting."
        return 0
      fi
    fi
  fi
}

# Install ActiveMQ broker
install_activemq_broker() {
  echo "Installing prerequisite packages..."
  apt_ensure wget ca-certificates tar file

  local WORK
  WORK="$(mktemp -d -t activemq.XXXXXX)"
  trap "rm -rf '$WORK'" EXIT
  cd "$WORK"

  echo "Downloading ${FILENAME}..."
  wget -q -O "$FILENAME" "$URL"

  echo "Verifying archive..."
  file "$FILENAME" | grep -qi 'gzip compressed data' || {
    echo "ERROR: Downloaded file isn't a gzip tarball (mirror may have returned HTML)."
    return 1
  }

  echo "Extracting ActiveMQ ${ACTIVEMQ_VERSION}..."
  tar -xzf "$FILENAME"

  local SRC_DIR="apache-activemq-${ACTIVEMQ_VERSION}"
  [ -d "$SRC_DIR" ] || { 
    echo "ERROR: '${SRC_DIR}' not found after extract."
    return 1
  }

  echo "Installing to ${INSTALL_DIR}..."
  $SUDO mkdir -p "$(dirname "$INSTALL_DIR")"
  $SUDO mv "$SRC_DIR" "$INSTALL_DIR"

  # Verify installation
  if [ -x "${INSTALL_DIR}/bin/activemq" ]; then
    echo "ActiveMQ installed at: ${INSTALL_DIR}"
    echo "Start: ${INSTALL_DIR}/bin/activemq start"
    echo "Stop : ${INSTALL_DIR}/bin/activemq stop"
  else
    echo "ERROR: activemq script not found/executable in ${INSTALL_DIR}/bin"
    return 1
  fi
}

# Configure ActiveMQ for remote access
configure_remote_access() {
  local jetty_config="${INSTALL_DIR}/conf/jetty.xml"
  
  if [ ! -f "$jetty_config" ]; then
    echo "Warning: jetty.xml not found at $jetty_config"
    return 0
  fi
  
  echo "Configuring ActiveMQ for remote access..."
  
  # Backup original
  if [ ! -f "${jetty_config}.ORIGINAL" ]; then
    $SUDO cp "$jetty_config" "${jetty_config}.ORIGINAL"
  fi
  
  # Get Pi IP address
  local pi_ip
  pi_ip=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "0.0.0.0")
  
  echo "Configuring ActiveMQ to listen on: $pi_ip"
  
  # Replace 127.0.0.1 with actual IP or 0.0.0.0 for all interfaces
  $SUDO sed -i "s/127\.0\.0\.1/$pi_ip/g" "$jetty_config"
  
  # Enable HTTPS connector if not already enabled
  if grep -q "Enable this connector if you wish to use https" "$jetty_config"; then
    echo "Enabling HTTPS connector..."
    # This is a more complex sed operation to uncomment the HTTPS section
    # For now, we'll just note it needs manual configuration
    echo "Note: HTTPS connector may need manual configuration in $jetty_config"
  fi
  
  echo "Remote access configuration completed"
}

# Set up systemctl service
setup_systemctl_service() {
  local service_file="/etc/systemd/system/activemq.service"
  
  echo "Setting up ActiveMQ systemctl service..."
  
  # Create service file
  $SUDO tee "$service_file" >/dev/null << EOF
[Unit]
Description=ActiveMQ Message Broker
After=network.target

[Service]
User=root
Type=forking
Restart=on-failure
RestartSec=10
ExecStart=${INSTALL_DIR}/bin/activemq start
ExecStop=${INSTALL_DIR}/bin/activemq stop
KillSignal=SIGTERM
TimeoutStopSec=30

# Ensure ActiveMQ starts in its own directory
WorkingDirectory=${INSTALL_DIR}

[Install]
WantedBy=multi-user.target
EOF

  # Reload systemd and enable service
  $SUDO systemctl daemon-reload
  
  echo "Starting and enabling ActiveMQ service..."
  $SUDO systemctl enable activemq
  
  # Start the service
  if $SUDO systemctl start activemq; then
    echo "ActiveMQ service started successfully"
    
    # Wait a moment and check status
    sleep 3
    if $SUDO systemctl is-active activemq >/dev/null; then
      echo "ActiveMQ service is running"
      
      # Show connection information
      local pi_ip
      pi_ip=$(hostname -I | awk '{print $1}')
      echo ""
      echo "ActiveMQ Web Console: http://$pi_ip:8161/admin"
      echo "Default login: admin/admin"
      echo "ActiveMQ Broker URL: tcp://$pi_ip:61616"
    else
      echo "WARNING: ActiveMQ service started but may not be healthy"
      echo "Check status with: sudo systemctl status activemq"
    fi
  else
    echo "WARNING: Failed to start ActiveMQ service"
    echo "Check logs with: sudo journalctl -u activemq"
  fi
}

# Verify ActiveMQ installation and service
verify_activemq_service() {
  echo "Verifying ActiveMQ installation..."
  
  # Check if ActiveMQ binary is executable
  if [ -x "${INSTALL_DIR}/bin/activemq" ]; then
    echo "ActiveMQ binary is executable"
  else
    echo "ERROR: ActiveMQ binary not found or not executable"
    return 1
  fi
  
  # Check service status
  if systemctl is-enabled activemq >/dev/null 2>&1; then
    echo "ActiveMQ service is enabled"
  else
    echo "WARNING: ActiveMQ service is not enabled"
  fi
  
  # Check if ActiveMQ is listening on expected ports
  if netstat -an 2>/dev/null | grep -q ":61616.*LISTEN"; then
    echo "ActiveMQ broker listening on port 61616"
  else
    echo "WARNING: ActiveMQ broker not listening on port 61616"
  fi
  
  if netstat -an 2>/dev/null | grep -q ":8161.*LISTEN"; then
    echo "ActiveMQ web console listening on port 8161"
  else
    echo "WARNING: ActiveMQ web console not listening on port 8161"
  fi
  
  echo "ActiveMQ verification completed"
}

# Main installation
install_activemq_full() {
  precheck
  install_activemq_broker
  configure_remote_access
  setup_systemctl_service
  verify_activemq_service
  
  echo ""
  echo "ActiveMQ installation and configuration completed!"
  echo ""
  echo "Service Management:"
  echo "- Start:   sudo systemctl start activemq"
  echo "- Stop:    sudo systemctl stop activemq" 
  echo "- Status:  sudo systemctl status activemq"
  echo "- Logs:    sudo journalctl -u activemq -f"
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_activemq_full
fi
