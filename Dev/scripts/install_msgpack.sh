#!/usr/bin/env bash
set -euo pipefail

# MessagePack C++ Installation Script
FORCE="${FORCE:-0}"

# Use sudo only if not already root
if [ "$(id -u)" -eq 0 ]; then SUDO=""; else SUDO="sudo"; fi
export DEBIAN_FRONTEND=noninteractive

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

have_msgpack() {
  # header-only lib usually installs these headers
  [ -f /usr/local/include/msgpack.hpp ] || [ -f /usr/include/msgpack.hpp ] && return 0
  # some distros lay out headers under msgpack/… only
  [ -f /usr/local/include/msgpack/msgpack.hpp ] || [ -f /usr/include/msgpack/msgpack.hpp ] && return 0
  return 1
}

verify_msgpack() {
  # Compile a tiny test that prints: [1,true,"example"]
  local tmpdir; tmpdir="$(mktemp -d -t msgpack.verify.XXXXXX)"
  cat > "${tmpdir}/test.cpp" <<'CPP'
#include <iostream>
#include <vector>
#include <string>
#include <msgpack.hpp>
int main() {
  std::vector<msgpack::type::variant> v;
  v.emplace_back(1);
  v.emplace_back(true);
  v.emplace_back(std::string("example"));
  msgpack::sbuffer sbuf;
  msgpack::pack(sbuf, v);
  msgpack::object_handle oh = msgpack::unpack(sbuf.data(), sbuf.size());
  std::cout << oh.get() << std::endl; // prints as JSON-ish
  return 0;
}
CPP
  g++ -std=c++20 -O2 -Wall -Wextra "${tmpdir}/test.cpp" -o "${tmpdir}/test"
  local out; out="$("${tmpdir}/test")"
  rm -rf "$tmpdir"
  [ "$out" = '[1,true,"example"]' ]
}

# Install MessagePack C++
install_msgpack() {
  # Check if already installed and skip if FORCE not set
  if [ "$FORCE" != "1" ] && have_msgpack; then
    echo "msgpack headers already present. Verifying..."
    if verify_msgpack; then
      echo "msgpack already installed and working — skipping."
      return 0
    else
      echo "msgpack headers found but verification failed; will rebuild."
    fi
  fi

  echo "Ensuring prerequisite build tools..."
  apt_ensure build-essential cmake unzip wget ca-certificates g++

  # Build from source
  local WORK
  WORK="$(mktemp -d -t msgpack.XXXXXX)"
  trap "rm -rf '$WORK'" EXIT
  cd "$WORK"

  echo "Fetching msgpack-c (cpp_master)..."
  wget -q https://github.com/msgpack/msgpack-c/archive/refs/heads/cpp_master.zip -O cpp_master.zip

  echo "Extracting source..."
  unzip -q cpp_master.zip
  local SRC_DIR="${WORK}/msgpack-c-cpp_master"
  
  if [ ! -d "$SRC_DIR" ]; then
    echo "ERROR: expected source dir not found."
    return 1
  fi

  echo "Configuring with CMake..."
  cmake -S "$SRC_DIR" -B "$SRC_DIR/build" -DMSGPACK_CXX20=ON

  echo "Building..."
  cmake --build "$SRC_DIR/build" -j"$(nproc)"

  echo "Installing to /usr/local..."
  $SUDO cmake --install "$SRC_DIR/build"
  $SUDO ldconfig 2>/dev/null || true

  echo "Verifying installation..."
  if verify_msgpack; then
    echo "MessagePack C++ successfully installed and verified!"
  else
    echo "ERROR: MessagePack C++ install/verify failed."
    return 1
  fi
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_msgpack
fi
