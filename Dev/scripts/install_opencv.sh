#!/usr/bin/env bash
set -euo pipefail

# OpenCV Installation Script
REQUIRED_OPENCV_VERSION="${REQUIRED_OPENCV_VERSION:-4.11.0}"
FORCE="${FORCE:-0}"

# Use sudo only if not already root
if [ "$(id -u)" -eq 0 ]; then SUDO=""; else SUDO="sudo"; fi
export DEBIAN_FRONTEND=noninteractive

# Utilities
need_cmd() { 
  command -v "$1" >/dev/null 2>&1
}

# Package management helper
apt_ensure() {
  local need=()
  for p in "$@"; do
    dpkg -s "$p" >/dev/null 2>&1 || need+=("$p")
  done
  if [ "${#need[@]}" -gt 0 ]; then
    $SUDO apt-get update
    $SUDO apt-get install -y --no-install-recommends "${need[@]}"
  fi
}

# Version comparison helper
version_ge() {
  dpkg --compare-versions "$1" ge "$2"
}

detect_opencv_version() {
  # Prefer C/C++ pkg-config
  if need_cmd pkg-config && pkg-config --exists opencv4 2>/dev/null; then
    pkg-config --modversion opencv4 2>/dev/null || true
    return
  fi

  # Fallback to Python cv2
  if need_cmd python3; then
    python3 - <<'PY' 2>/dev/null || true
import sys
try:
    import cv2
    print(cv2.__version__)
except Exception:
    pass
PY
    return
  fi

  echo ""
}

# Check if opencv is installed
is_opencv_installed() {
  local ver
  ver="$(detect_opencv_version)"
  [ -n "$ver" ] && return 0
  return 1
}

# Ensure all OpenCV build dependencies are available
ensure_opencv_dependencies() {
  echo "Installing OpenCV build dependencies..."
  
  # Core build tools
  apt_ensure build-essential cmake git pkg-config wget ca-certificates sed
  
  # Base OpenCV dependencies
  apt_ensure libgtk-3-dev libavcodec-dev libavformat-dev libswscale-dev \
    libv4l-dev libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
    gfortran openexr libatlas-base-dev python3-dev python3-numpy \
    libtbb-dev libdc1394-dev libopenexr-dev \
    libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev
    
  # Install TBB runtime - check for installable candidates
  if apt-cache policy libtbb2 2>/dev/null | grep -q "Candidate:.*[0-9]"; then
    apt_ensure libtbb2
  elif apt-cache policy libtbbmalloc2 2>/dev/null | grep -q "Candidate:.*[0-9]"; then
    apt_ensure libtbbmalloc2
  else
    echo "Warning: No installable TBB runtime package found, OpenCV will build without TBB support"
  fi
}

# Download OpenCV installation script to specified directory
download_opencv_script_to() {
  local work_dir="$1"
  ensure_opencv_dependencies

  echo "Downloading to: $work_dir"
  cd "$work_dir"

  local url="https://github.com/Qengineering/Install-OpenCV-Raspberry-Pi-64-bits/raw/main/OpenCV-4-11-0.sh"
  echo "Downloading OpenCV installer script..."
  
  if need_cmd wget; then
    if ! wget -q --max-redirect=5 -O OpenCV-4-11-0.sh "$url"; then
      echo "ERROR: Failed to download OpenCV script"
      return 1
    fi
  else
    if ! curl -fsSLo OpenCV-4-11-0.sh "$url"; then
      echo "ERROR: Failed to download OpenCV script"
      return 1
    fi
  fi
  
  if [ ! -f "OpenCV-4-11-0.sh" ]; then
    echo "ERROR: OpenCV script not found after download"
    return 1
  fi
  
  chmod +x OpenCV-4-11-0.sh
  echo "Download completed successfully"
}

modify_opencv() {
  local script_path="$1"
  
  if [ ! -f "$script_path" ]; then
    echo "ERROR: OpenCV script not found: $script_path"
    return 1
  fi
  
  echo "Editing OpenCV script at: $script_path"

  # Only touch lines if the flags exist
  if grep -q 'INSTALL_C_EXAMPLES=OFF' "$script_path"; then
    echo "Enable INSTALL_C_EXAMPLES..."
    sed -i 's/-D INSTALL_C_EXAMPLES=OFF/-D INSTALL_C_EXAMPLES=ON/' "$script_path"
  fi

  if grep -q 'INSTALL_PYTHON_EXAMPLES=OFF' "$script_path"; then
    echo "Enable INSTALL_PYTHON_EXAMPLES..."
    sed -i 's/-D INSTALL_PYTHON_EXAMPLES=OFF/-D INSTALL_PYTHON_EXAMPLES=ON/' "$script_path"
  fi
}

# Standard OpenCV build for x86_64 platforms
build_opencv_standard() {
  local WORK
  WORK="$(mktemp -d -t opencv-build.XXXXXX)"
  trap "rm -rf '$WORK'" EXIT
  cd "$WORK"
  
  echo "Downloading OpenCV $REQUIRED_OPENCV_VERSION source..."
  wget -q "https://github.com/opencv/opencv/archive/refs/tags/$REQUIRED_OPENCV_VERSION.tar.gz" -O opencv.tar.gz
  wget -q "https://github.com/opencv/opencv_contrib/archive/refs/tags/$REQUIRED_OPENCV_VERSION.tar.gz" -O opencv_contrib.tar.gz
  
  echo "Extracting OpenCV source..."
  tar -xzf opencv.tar.gz
  tar -xzf opencv_contrib.tar.gz
  
  cd "opencv-$REQUIRED_OPENCV_VERSION"
  mkdir -p build && cd build
  
  echo "Configuring OpenCV build..."
  cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D INSTALL_PYTHON_EXAMPLES=ON \
        -D INSTALL_C_EXAMPLES=ON \
        -D OPENCV_ENABLE_NONFREE=ON \
        -D OPENCV_EXTRA_MODULES_PATH="../../opencv_contrib-$REQUIRED_OPENCV_VERSION/modules" \
        -D PYTHON_EXECUTABLE="/usr/bin/python3" \
        -D BUILD_EXAMPLES=ON ..
        
  echo "Building OpenCV (this will take a while)..."
  make -j"$(nproc)"
  
  echo "Installing OpenCV..."
  $SUDO make install
  $SUDO ldconfig
}

run_opencv_script() {
  local script_path="$1"
  local arch
  arch="$(uname -m)"
  
  echo "Running OpenCV installer for architecture: $arch"
  
  # Check if we're on ARM (where Qengineering script works)
  if [[ "$arch" == "arm"* ]] || [[ "$arch" == "aarch64" ]]; then
    echo "ARM architecture detected - using Qengineering optimized script"
    
    # The Qengineering script expects sudo
    if ! need_cmd sudo; then
      echo "sudo not found; creating a no-op shim (you may be root)..."
      $SUDO ln -sf /bin/true /usr/local/bin/sudo
      hash -r || true
    fi

    # Clean up any previous OpenCV source and build directories
    echo "Cleaning previous OpenCV installation artifacts..."
    rm -rf /root/opencv /root/opencv_contrib

    bash "$script_path"
  else
    echo "x86_64 architecture detected - using standard OpenCV build"
    build_opencv_standard
  fi
}

verify_installed() {
  local v
  v="$(detect_opencv_version)"
  if [ -z "$v" ]; then
    echo "OpenCV not detected after install."
    return 1
  fi
  echo "Detected OpenCV version: $v"
  if version_ge "$v" "$REQUIRED_OPENCV_VERSION"; then
    echo "OK: OpenCV $v ≥ required $REQUIRED_OPENCV_VERSION"
    return 0
  else
    echo "ERROR: OpenCV $v < required $REQUIRED_OPENCV_VERSION"
    return 1
  fi
}

# Install OpenCV
install_opencv() {
  # Check if already installed (unless FORCE=1)
  local current
  current="$(detect_opencv_version)"
  if [ -n "$current" ] && [ "$FORCE" != "1" ]; then
    if version_ge "$current" "$REQUIRED_OPENCV_VERSION"; then
      echo "OpenCV already installed (version $current ≥ $REQUIRED_OPENCV_VERSION). Skipping."
      return 0
    else
      echo "OpenCV $current found (< $REQUIRED_OPENCV_VERSION). Will install/upgrade."
    fi
  elif [ "$FORCE" = "1" ]; then
    echo "FORCE=1 set — proceeding with installation regardless of current version."
  fi

  # Create single temp directory for entire installation
  local WORK
  WORK="$(mktemp -d -t opencv.XXXXXX)"
  trap "rm -rf '$WORK'" EXIT
  
  local script_path="${WORK}/OpenCV-4-11-0.sh"
  
  # Download script
  download_opencv_script_to "$WORK"
  
  # Modify and run
  modify_opencv "$script_path"
  run_opencv_script "$script_path"

  echo "Verifying OpenCV installation..."
  if verify_installed; then
    echo "OpenCV installation completed successfully."
  else
    echo "OpenCV installation completed but version check failed."
    return 1
  fi
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_opencv
fi
