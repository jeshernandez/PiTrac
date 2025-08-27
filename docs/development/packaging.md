---
layout: default
title: Packaging Guide
parent: Development Guide
nav_order: 4
---

# PiTrac Packaging Guide

This guide covers the PiTrac packaging system for creating distributable Debian packages.

## Overview

PiTrac uses Debian packaging (.deb) as its primary distribution format, providing:
- Single file installation: `sudo apt install ./pitrac_*.deb`
- Automatic dependency management
- SystemD service integration
- Clean uninstall via `apt remove`

## Build Scripts

### Main Build Script
```bash
cd packaging
./build.sh [action]
```

Actions:
- `deps` - Build dependency artifacts
- `build` - Build PiTrac binary (default)
- `all` - Build dependencies then PiTrac
- `dev` - Build and install on Pi
- `clean` - Remove artifacts

### Package Build Script
```bash
./build-apt-package.sh
```

Creates `.deb` package in `build/packages/` using pre-built artifacts.

## Package Structure

```
pitrac_1.0.0_arm64.deb
├── DEBIAN/
│   ├── control          # Package metadata
│   ├── postinst        # Post-installation script
│   ├── prerm           # Pre-removal script
│   └── conffiles       # Config file list
├── usr/
│   ├── bin/
│   │   └── pitrac      # CLI interface (bashly-generated)
│   ├── lib/
│   │   └── pitrac/
│   │       ├── pitrac_lm                   # Main binary
│   │       ├── libopencv_*.so.411         # OpenCV 4.11.0
│   │       ├── libactivemq-cpp.so.19      # ActiveMQ 3.9.5
│   │       ├── liblgpio.so.0              # GPIO library
│   │       ├── tomee-wrapper.sh           # TomEE launcher
│   │       └── ImageProcessing/
│   │           └── CameraTools/           # Camera scripts
│   └── share/
│       └── pitrac/
│           ├── webapp/
│           │   └── golfsim.war            # Web interface
│           └── test-images/               # Test images
├── etc/
│   ├── pitrac/
│   │   ├── pitrac.yaml                    # Main config
│   │   ├── golf_sim_config.json          # Legacy config
│   │   └── config/
│   │       ├── parameter-mappings.yaml    # Parameter maps
│   │       └── settings-*.yaml           # Setting templates
│   └── systemd/
│       └── system/
│           ├── pitrac.service             # Main service
│           └── tomee.service             # Web server
└── opt/
    └── tomee/                             # TomEE server files
```

## Dependencies

### Bundled Libraries (Built from Source)
- **OpenCV 4.11.0** - Computer vision (Debian has 4.6.0)
- **ActiveMQ-CPP 3.9.5** - Messaging (not in repos)
- **lgpio 0.2.2** - GPIO control (not in repos)
- **msgpack-cxx 6.1.1** - Serialization headers

### System Dependencies (from APT)
```
libboost-system1.74.0
libboost-thread1.74.0
libcamera0.0.3
libcamera-dev
rpicam-apps-lite | libcamera-apps-lite
gpiod
default-jre-headless
```

## Service Configuration

### pitrac.service
```ini
[Unit]
Description=PiTrac Launch Monitor
After=network.target activemq.service tomee.service

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi
Environment="LD_LIBRARY_PATH=/usr/lib/pitrac"
ExecStart=/usr/bin/pitrac run --foreground --system_mode=camera1
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

### tomee.service
```ini
[Unit]
Description=Apache TomEE for PiTrac
After=network.target

[Service]
Type=forking
User=tomee
ExecStart=/usr/lib/pitrac/tomee-wrapper.sh start
ExecStop=/usr/lib/pitrac/tomee-wrapper.sh stop
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

## Installation Scripts

### Post-Installation (postinst)
- Creates user directories (`~/.pitrac`, `~/LM_Shares`)
- Adds user to required groups (video, gpio, i2c, spi)
- Configures boot settings in `/boot/firmware/config.txt`
- Applies Boost 1.74 C++20 compatibility fix
- Sets up TomEE user and permissions

### Pre-Removal (prerm)
- Stops and disables services
- Basic cleanup only (preserves user data)

## Building Packages

### Prerequisites
Build dependency artifacts first (one-time, ~60 min):
```bash
cd packaging
./scripts/build-all-deps.sh
```

This creates artifacts in `deps-artifacts/`:
- `opencv-4.11.0-arm64.tar.gz`
- `activemq-cpp-3.9.5-arm64.tar.gz`
- `lgpio-0.2.2-arm64.tar.gz`
- `msgpack-cxx-6.1.1-arm64.tar.gz`
- `tomee-10.1.0-plume-arm64.tar.gz`
- `golfsim-1.0.0-noarch.war`

### Package Creation
```bash
# Build PiTrac binary
./build.sh build

# Create .deb package
./build-apt-package.sh

# Package output
ls build/packages/pitrac_*.deb
```

## CLI Commands

The package includes a comprehensive CLI at `/usr/bin/pitrac`:

### Core Commands
- `pitrac run` - Start launch monitor
- `pitrac stop` - Stop launch monitor
- `pitrac status` - Show system status
- `pitrac setup` - Initial setup wizard
- `pitrac version` - Version info

### Configuration
- `pitrac config show` - Display config
- `pitrac config edit` - Edit config
- `pitrac config set KEY VALUE` - Set value
- `pitrac config get KEY` - Get value

### Testing
- `pitrac test quick` - Test with included images
- `pitrac test pulse` - Test strobe lights
- `pitrac test camera` - Camera test
- `pitrac test gspro` - Simulator test

### Camera Control
- `pitrac camera list` - List cameras
- `pitrac camera trigger external|internal` - Trigger mode
- `pitrac camera test` - Test camera

### Service Management
- `pitrac service start|stop|restart|status` - Control service
- `pitrac tomee start|stop|status` - TomEE control
- `pitrac activemq start|stop|status` - ActiveMQ control

## Testing Installation

```bash
# Install package
sudo apt install ./pitrac_1.0.0_arm64.deb

# Verify installation
dpkg -l | grep pitrac
pitrac version

# Test functionality
pitrac test quick

# Check services
systemctl status pitrac
systemctl status tomee
```

## Troubleshooting

### Missing Dependencies
```bash
# Install missing system packages
sudo apt update
sudo apt --fix-broken install
```

### Service Issues
```bash
# View logs
journalctl -u pitrac -f

# Check status
systemctl status pitrac -l
```

### Library Loading
```bash
# Update library cache
sudo ldconfig /usr/lib/pitrac

# Check libraries
ldd /usr/lib/pitrac/pitrac_lm
```

## Version Information

Current versions in use:
- Package Version: 1.0.0 (from control file)
- OpenCV: 4.11.0
- ActiveMQ-CPP: 3.9.5
- lgpio: 0.2.2
- msgpack-cxx: 6.1.1
- TomEE: 10.1.0-plume

## Notes

- Test images are copied from `Software/LMSourceCode/Images/`
- The CLI is generated using bashly from `packaging/src/`
- Architecture support: arm64 (primary), armhf, amd64