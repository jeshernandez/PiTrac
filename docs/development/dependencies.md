---
layout: default
title: Dependencies Management
parent: Development Guide
nav_order: 8
---

# Dependencies Management

PiTrac relies on several external libraries, some requiring builds from source for compatibility with Raspberry Pi hardware and OS versions.

## Core Dependencies

PiTrac's dependencies as defined in `Software/LMSourceCode/ImageProcessing/meson.build`:

| Dependency | Required Version | Source | Notes |
|------------|-----------------|--------|-------|
| OpenCV | ≥4.9.0 | Built from source | Debian provides 4.6.0 |
| Boost | ≥1.74.0 | System package | Threading, logging, filesystem modules |
| ActiveMQ-CPP | Any | Built from source | Not in Debian repos |
| lgpio | Any | Built from source | Pi 5 GPIO compatibility |
| libcamera | System | System package | Kernel-dependent |
| msgpack-cxx | Any | Built from source | Serialization library |
| yaml-cpp | Any | System package | Configuration parsing |
| fmt | Any | System package | String formatting |
| OpenSSL | Any | System package | Security/encryption |
| APR-1 | Any | System package | ActiveMQ dependency |

## Build Scripts

All dependency build scripts are located in `packaging/scripts/`:

- `build-opencv.sh` - Builds OpenCV 4.11.0 for ARM64
- `build-activemq.sh` - Builds ActiveMQ-CPP 3.9.5
- `build-lgpio.sh` - Builds lgpio library
- `build-msgpack.sh` - Builds msgpack-cxx
- `build-all-deps.sh` - Orchestrates all dependency builds

### Building All Dependencies

```bash
cd packaging
./scripts/build-all-deps.sh
```

This creates artifacts in `packaging/deps-artifacts/`:
- `opencv-4.11.0-arm64.tar.gz`
- `activemq-cpp-3.9.5-arm64.tar.gz`  
- `lgpio-0.2.2-arm64.tar.gz`
- `msgpack-cxx-6.1.1-arm64.tar.gz`

## Docker-Based Build System

PiTrac uses Docker containers to build dependencies reproducibly:

### OpenCV Build
The `packaging/Dockerfile.opencv` builds OpenCV 4.11.0 with:
- DNN support for YOLO models
- TBB for parallelism
- V4L/libcamera support
- Selected modules: core, imgproc, imgcodecs, calib3d, features2d, highgui, videoio, photo, dnn, objdetect

### ActiveMQ-CPP Build
The `packaging/Dockerfile.activemq` builds ActiveMQ-CPP 3.9.5 with APR dependencies.

### lgpio Build
The `packaging/Dockerfile.lgpio` builds lgpio from the joan2937/lg repository for Pi 5 GPIO support.

### msgpack-cxx Build  
The `packaging/Dockerfile.msgpack` builds msgpack-cxx from the cpp_master branch as a header-only library.

## Build System

### Primary: Meson/Ninja
PiTrac uses Meson as its primary build system:

```bash
cd Software/LMSourceCode/ImageProcessing
meson setup build --buildtype=release
ninja -C build pitrac_lm
```

### Package Building
The main packaging orchestrator:

```bash
cd packaging
./build.sh build     # Build PiTrac binary
./build.sh all       # Build everything including dependencies
```

### APT Package Creation
```bash
cd packaging
./build-apt-package.sh
```

Creates a `.deb` file in `packaging/build/package/`.

## Platform Differences

### Raspberry Pi 4 vs Pi 5

| Aspect | Pi 4 | Pi 5 |
|--------|------|------|
| Config location | `/boot/config.txt` | `/boot/firmware/config.txt` |
| Camera tools | `libcamera-*` | `rpicam-*` |
| GPIO chip | 0 | 4 |
| Camera package | libcamera-apps | rpicam-apps |

### Architecture Support
- Primary: ARM64 (aarch64)
- Secondary: ARMv7 (32-bit ARM)
- Development: x86_64

## Dependency Resolution

### PKG-Config
Ensure libraries are discoverable:

```bash
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
pkg-config --modversion opencv4
```

### Library Loading
Runtime library path setup:

```bash
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
ldd /usr/bin/pitrac_lm  # Verify library linking
```

## Troubleshooting

### OpenCV Not Found
```bash
# Check installation
pkg-config --modversion opencv4

# Set environment
export OpenCV_DIR=/opt/opencv/lib/cmake/opencv4
export PKG_CONFIG_PATH=/opt/opencv/lib/pkgconfig:$PKG_CONFIG_PATH
sudo ldconfig
```

### Missing Dependencies
```bash
# Check what's missing
meson setup build  # Will report missing dependencies

# Debug library loading
LD_DEBUG=libs ./pitrac_lm 2>&1 | head -20
```

### Build Failures
```bash
# Clean rebuild
rm -rf build
meson setup build --buildtype=release

# Check for architecture mismatches
file build/*.o  # Should all be same architecture
```

## Package Installation

The APT package installs:
- Binary: `/usr/lib/pitrac/pitrac_lm`
- CLI: `/usr/bin/pitrac`
- Config: `/etc/pitrac/`
- Test images: `/usr/share/pitrac/test-images/`
- Services: systemd units for pitrac and tomee

## Summary

PiTrac's dependency management uses Docker for reproducible builds, creating reusable artifacts that speed up development. The combination of system packages and custom-built libraries ensures compatibility across different Raspberry Pi models while maintaining optimal performance.