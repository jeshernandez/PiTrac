#!/usr/bin/env bash
set -euo pipefail

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

# Check if activemq cpp is installed
is_activemq_cpp_installed() {
  # Check if libactivemq-cpp is available via ldconfig
  if ldconfig -p 2>/dev/null | grep -q "libactivemq-cpp"; then
    return 0
  fi

  # Fallback: check if the header exists
  if [ -f "/usr/local/include/activemq/library/ActiveMQCPP.h" ] || \
     [ -f "/usr/include/activemq/library/ActiveMQCPP.h" ]; then
    return 0
  fi

  return 1
}

# Install ActiveMQ C++ CMS
install_activemq_cpp() {
  if is_activemq_cpp_installed; then
    echo "ActiveMQ-CPP already installed. Skipping build."
    return 0
  fi

  echo "Installing prerequisites..."
  apt_ensure \
    autoconf \
    automake \
    libtool \
    pkg-config \
    build-essential \
    libssl-dev \
    libapr1-dev \
    libaprutil1-dev \
    libcppunit-dev \
    uuid-dev \
    doxygen \
    git

  # Build ActiveMQ-CPP
  local WORK_DIR
  WORK_DIR="$(mktemp -d -t activemq-cpp.XXXXXX)"
  trap "rm -rf '$WORK_DIR'" EXIT
  cd "$WORK_DIR"

  echo "Cloning ActiveMQ-CPP..."
  git clone https://gitbox.apache.org/repos/asf/activemq-cpp.git
  cd activemq-cpp/activemq-cpp

  echo "Configuring..."
  ./autogen.sh
  ./configure

  echo "Building..."
  make -j"$(nproc)"

  echo "Installing..."
  $SUDO make install
  $SUDO ldconfig 2>/dev/null || true

  echo "Generating Doxygen docs..."
  make doxygen-run || echo "Doxygen documentation generation skipped."

  echo "Running unit tests..."
  make check || echo "Unit tests skipped or failed."

  echo "ActiveMQ-CPP installation complete."
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_activemq_cpp
fi
