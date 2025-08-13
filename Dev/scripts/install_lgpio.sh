#!/usr/bin/env bash
set -euo pipefail

# LGPIO Library Installation Script
CONFIG_FILE="/boot/firmware/config.txt"
SPI_LINE_ON="dtparam=spi=on"
SPI_LINE_OFF="dtparam=spi=off"

# Resolve assets path relative to this script
SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
ASSETS_DIR="${SCRIPT_DIR}/assets"

# Use sudo only if not already root
if [ "$(id -u)" -eq 0 ]; then SUDO=""; else SUDO="sudo"; fi
export DEBIAN_FRONTEND=noninteractive

# Check if lgpio is installed
lgpio_already_installed() {
  # Check if library is available via ldconfig
  if ldconfig -p 2>/dev/null | grep -q 'liblgpio\.so'; then
    return 0
  fi
  
  # Check for pkg-config file or header
  [ -f /usr/lib/pkgconfig/lgpio.pc ] && return 0
  [ -f /usr/local/lib/pkgconfig/lgpio.pc ] && return 0
  [ -f /usr/include/lgpio.h ] && return 0
  [ -f /usr/local/include/lgpio.h ] && return 0
  
  return 1
}

# Check if SPI is enabled
spi_already_enabled() {
  [ -f "$CONFIG_FILE" ] && grep -q "^${SPI_LINE_ON}" "$CONFIG_FILE"
}

# Install LGPIO library
install_lgpio() {
  if lgpio_already_installed; then
    echo "LGPIO already installed; skipping build/install."
    return 0
  fi

  # Ensure required packages are installed
  local packages=("wget" "unzip" "build-essential" "ca-certificates")
  for pkg in "${packages[@]}"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
      echo "Installing $pkg..."
      $SUDO apt-get update
      $SUDO apt-get install -y --no-install-recommends "$pkg"
    fi
  done

  WORK_DIR="$(mktemp -d -t lgpio.XXXXXX)"
  trap "rm -rf '$WORK_DIR'" EXIT

  echo "Download LGPIO into: $WORK_DIR"
  cd "$WORK_DIR"

  if command -v wget >/dev/null 2>&1; then
    wget -q http://abyz.me.uk/lg/lg.zip
  elif command -v curl >/dev/null 2>&1; then
    curl -fsSLo lg.zip http://abyz.me.uk/lg/lg.zip
  else
    echo "ERROR: Neither wget nor curl available after installation attempt"
    return 1
  fi

  echo "Unpacking LGPIO..."
  unzip -q lg.zip
  cd lg

  echo "Building LGPIO..."
  make
  $SUDO make install
  
  # Update library cache
  $SUDO ldconfig 2>/dev/null || true
  
  echo "LGPIO installed."
}

copy_lgpio_pc() {
  local target_dir="/usr/lib/pkgconfig"
  local src_pc="${ASSETS_DIR}/lgpio.pc"

  # If pkg-config already sees lgpio, skip copying
  if pkg-config --exists lgpio 2>/dev/null; then
    echo "lgpio.pc already available via pkg-config; skipping copy."
    return 0
  fi

  echo "Copying lgpio.pc to ${target_dir}..."
  if [ ! -f "$src_pc" ]; then
    echo "WARNING: ${src_pc} not found. Skipping lgpio.pc copy."
    return 0
  fi

  $SUDO mkdir -p "$target_dir"
  $SUDO cp "$src_pc" "${target_dir}/"

  if [ -f "${target_dir}/lgpio.pc" ]; then
    echo "Successfully copied lgpio.pc to ${target_dir}"
  else
    echo "Issue copying lgpio.pc to ${target_dir}"
    exit 1
  fi
}

enable_spi() {
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "WARNING: ${CONFIG_FILE} not found. Are you on Raspberry Pi OS? Skipping SPI enable."
    return 0
  fi

  if spi_already_enabled; then
    echo "SPI already enabled in $CONFIG_FILE"
  else
    echo "Enabling SPI pins in $CONFIG_FILE..."
    if grep -q "^${SPI_LINE_OFF}" "$CONFIG_FILE"; then
      $SUDO sed -i "s/^${SPI_LINE_OFF}/${SPI_LINE_ON}/" "$CONFIG_FILE"
    else
      echo "$SPI_LINE_ON" | $SUDO tee -a "$CONFIG_FILE" >/dev/null
    fi
  fi

  # Validate device nodes (may require reboot on real hardware)
  if [ -e /dev/spidev0.0 ] && [ -e /dev/spidev0.1 ]; then
    echo "SPI devices found: /dev/spidev0.0 and /dev/spidev0.1"
  else
    echo "SPI devices not found yet. You may need to reboot on Pi hardware."
  fi
}

# Main installation
install_lgpio_full() {
  install_lgpio
  copy_lgpio_pc
  enable_spi
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_lgpio_full
fi
