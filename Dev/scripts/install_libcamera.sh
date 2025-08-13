#!/usr/bin/env bash
set -euo pipefail

# Libcamera and RpiCam Apps Installation Script
REQUIRED_RPICAM_APPS_VERSION="${REQUIRED_RPICAM_APPS_VERSION:-1.5.3}"

# Use sudo only if not already root
if [ "$(id -u)" -eq 0 ]; then SUDO=""; else SUDO="sudo"; fi
export DEBIAN_FRONTEND=noninteractive

# Utilities
need_cmd() { 
  command -v "$1" >/dev/null 2>&1
}

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

# Version comparison helper
version_ge() {
  dpkg --compare-versions "$1" ge "$2"
}

# Check if libcamera is installed
have_libcamera() {
  # Try common pkg-config names
  if pkg-config --exists libcamera 2>/dev/null; then
    return 0
  fi
  if pkg-config --exists libcamera-base 2>/dev/null; then
    return 0
  fi
  # Fallback: look for headers as a last resort
  [ -e /usr/include/libcamera/libcamera.h ] || [ -e /usr/local/include/libcamera/libcamera.h ]
}

rpicam_apps_meet_requirement() {
  if ! need_cmd rpicam-still; then
    return 1
  fi
  local installed ver
  installed="$(rpicam-still --version 2>/dev/null | awk '/rpicam-apps build/ {print $3}')"
  ver="${installed#v}"
  [ -n "$ver" ] && version_ge "$ver" "$REQUIRED_RPICAM_APPS_VERSION"
}

# Installation functions
install_libraries() {
  echo "Ensuring prerequisite libraries..."
  apt_ensure \
    git \
    python3 \
    python3-pip \
    python3-graphviz \
    python3-sphinx \
    python3-yaml \
    python3-ply \
    python3-jinja2 \
    doxygen \
    libevent-dev \
    pybind11-dev \
    libavdevice-dev \
    qtbase5-dev libqt5core5a libqt5gui5 libqt5widgets5 \
    meson \
    cmake \
    ninja-build \
    pkg-config \
    build-essential \
    libglib2.0-dev \
    libgstreamer-plugins-base1.0-dev \
    unzip \
    wget \
    ca-certificates
}

install_libcamera() {
  if have_libcamera; then
    echo "libcamera already present (pkg-config found it). Skipping build."
    return 0
  fi

  echo "Downloading and building libcamera..."
  local WORK
  WORK="$(mktemp -d -t rpi-build.XXXXXX)"
  trap "rm -rf '$WORK'" EXIT
  cd "$WORK"

  git clone https://github.com/raspberrypi/libcamera.git
  cd libcamera

  export PKEXEC_UID="${PKEXEC_UID:-99999}"

  echo "Meson setup..."
  meson setup build \
    --buildtype=release \
    -Dpipelines=rpi/vc4,rpi/pisp \
    -Dipas=rpi/vc4,rpi/pisp \
    -Dv4l2=enabled \
    -Dgstreamer=enabled \
    -Dtest=false \
    -Dlc-compliance=disabled \
    -Dcam=disabled \
    -Dqcam=disabled \
    -Ddocumentation=disabled \
    -Dpycamera=enabled

  echo "Ninja build..."
  ninja -C build

  echo "Installing libcamera..."
  $SUDO ninja -C build install
  echo "libcamera installed."
}

install_rpicam_apps() {
  if rpicam_apps_meet_requirement; then
    echo "rpicam-apps already meets requirement (>= ${REQUIRED_RPICAM_APPS_VERSION}). Skipping build."
    return 0
  fi

  echo "Installing rpicam pre-required libraries..."
  apt_ensure libboost-program-options-dev libdrm-dev libexif-dev

  echo "Downloading and building rpicam-apps..."
  local WORK
  WORK="$(mktemp -d -t rpi-build.XXXXXX)"
  trap "rm -rf '$WORK'" EXIT
  cd "$WORK"

  git clone https://github.com/raspberrypi/rpicam-apps.git
  cd rpicam-apps

  echo "Meson setup for rpicam-apps..."
  meson setup build \
    -Denable_libav=enabled \
    -Denable_drm=enabled \
    -Denable_egl=enabled \
    -Denable_qt=enabled \
    -Denable_opencv=enabled \
    -Denable_tflite=disabled \
    -Denable_hailo=disabled

  echo "Compiling rpicam-apps..."
  meson compile -C build

  echo "Installing rpicam-apps..."
  $SUDO meson install -C build
  $SUDO ldconfig 2>/dev/null || true

  echo "rpicam-apps installed."
}

verify_installation() {
  echo "Verifying rpicam-apps installation..."
  if ! need_cmd rpicam-still; then
    echo "ERROR: rpicam-still not found on PATH."
    exit 2
  fi

  local installed ver
  installed="$(rpicam-still --version 2>/dev/null | awk '/rpicam-apps build/ {print $3}')"
  ver="${installed#v}"

  if [ -z "$ver" ]; then
    echo "WARNING: Could not determine rpicam-apps version."
    exit 0
  fi

  if version_ge "$ver" "$REQUIRED_RPICAM_APPS_VERSION"; then
    echo "OK: rpicam-apps $ver >= required $REQUIRED_RPICAM_APPS_VERSION"
    exit 0
  else
    echo "ERROR: rpicam-apps $ver < required $REQUIRED_RPICAM_APPS_VERSION"
    exit 1
  fi
}

# Main installation
install_libcamera_full() {
  install_libraries
  install_libcamera
  install_rpicam_apps
  verify_installation
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_libcamera_full
fi
