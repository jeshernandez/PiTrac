---
layout: default
title: Docker Development
parent: Development Guide
nav_order: 7
---

# Docker Development

PiTrac uses Docker for building dependencies and creating reproducible builds for ARM64 architecture.

## Overview

The Docker build system is located in the `packaging/` directory and focuses on:
- Building complex dependencies from source (OpenCV, ActiveMQ-CPP, lgpio)
- Creating reusable artifacts for faster rebuilds
- Cross-platform compilation from x86 to ARM64

## Existing Docker Files

### Dependency Builders

Located in `packaging/`:

1. **Dockerfile.opencv** - Builds OpenCV 4.11.0 from source
   - Creates `/opencv-4.11.0-arm64.tar.gz` artifact
   - Includes contrib modules and DNN support
   - Configured for PiTrac requirements

2. **Dockerfile.activemq** - Builds ActiveMQ-CPP 3.9.5
   - Creates `/activemq-cpp-3.9.5-arm64.tar.gz` artifact
   - Required for message broker integration

3. **Dockerfile.lgpio** - Builds lgpio 0.2.2
   - Creates `/lgpio-0.2.2-arm64.tar.gz` artifact
   - GPIO library not available in Debian repos

4. **Dockerfile.msgpack** - Builds MessagePack C++ 6.1.1
   - Creates `/msgpack-cxx-6.1.1-arm64.tar.gz` artifact
   - Header-only serialization library

5. **Dockerfile.pitrac** - Main application builder
   - Uses pre-built artifacts from dependency builders
   - Builds the PiTrac binary
   - Configured for ARM64 target

6. **Dockerfile.tomee** - TomEE web application server
   - Builds the Java web interface component

7. **Dockerfile.bashly** - Bashly CLI tool builder
   - Used for generating the pitrac CLI

### Web Application Docker

Located in `Software/LMSourceCode/ImageProcessing/golfsim_tomee_webapp/`:

- **Dockerfile** - TomEE web application container
- **docker-compose.yml** - Orchestrates TomEE with ActiveMQ

## Build System

### Main Build Script

The `packaging/build.sh` script orchestrates the Docker build process:

```bash
# Build dependency artifacts (one-time)
./build.sh deps

# Build PiTrac using artifacts
./build.sh build

# Build everything
./build.sh all

# Interactive shell for development
./build.sh shell
```

### Dependency Build Scripts

Located in `packaging/scripts/`:
- `build-all-deps.sh` - Builds all dependencies
- `build-opencv.sh` - OpenCV builder
- `build-activemq.sh` - ActiveMQ-CPP builder
- `build-lgpio.sh` - lgpio builder
- `build-msgpack.sh` - MessagePack builder
- `build-tomee.sh` - TomEE builder

## Docker Compose

The TomEE web application includes a docker-compose.yml that sets up:

```yaml
services:
  activemq:
    image: apache/activemq-classic:6.1.4
    ports:
      - "61616:61616"  # ActiveMQ port
      - "8161:8161"    # Web console
      
  tomee:
    build:
      context: .
    ports:
      - "8080:8080"    # TomEE port
    environment:
      - PITRAC_MSG_BROKER_FULL_ADDRESS=tcp://activemq:61616
```

## Cross-Platform Building

PiTrac targets ARM64 (Raspberry Pi 4/5) architecture. When building on x86_64:

```bash
# Setup QEMU for ARM64 emulation
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# Build for ARM64
docker build --platform linux/arm64 -f Dockerfile.pitrac .
```

## Artifacts Directory

Pre-built dependencies are stored in `packaging/deps-artifacts/`:
- `opencv-4.11.0-arm64.tar.gz` - OpenCV libraries
- `activemq-cpp-3.9.5-arm64.tar.gz` - ActiveMQ libraries
- `lgpio-0.2.2-arm64.tar.gz` - GPIO library  
- `msgpack-cxx-6.1.1-arm64.tar.gz` - MessagePack headers

These artifacts are built once and reused for faster builds.

## Building PiTrac

### Quick Start

```bash
cd packaging

# First time: build all dependencies (~60 minutes)
./scripts/build-all-deps.sh

# Build PiTrac (~2 minutes)
./build.sh build

# Create APT package
./build-apt-package.sh
```

### Docker Build Process

1. **Base Image**: Uses `debian:bookworm-slim` for ARM64
2. **Raspberry Pi Repository**: Adds RPi archive for libcamera packages
3. **Pre-built Dependencies**: Extracts artifacts to `/opt/`
4. **System Dependencies**: Installs from Debian/RPi repos
5. **Build**: Compiles PiTrac using Meson/Ninja

## Key Features

### Build Optimization
- Separates heavy dependency builds from application builds
- Reuses pre-built artifacts to reduce build time from ~60min to ~2min
- Uses Docker layer caching

### Platform Support
- Primary target: ARM64 (Raspberry Pi 4/5)
- Cross-compilation from x86_64 using QEMU
- Native ARM64 builds on Pi or ARM servers

### Package Management
- Creates APT packages for easy installation
- Includes all custom-built dependencies
- System dependencies handled by APT

## Limitations

The current Docker implementation:
- Does not include a Dockerfile.dev (development container)
- Does not include Kubernetes or Docker Swarm configurations
- Does not include a docker-compose.prod.yml
- Does not include .devcontainer configuration
- Does not include automated Docker registry publishing

## Future Improvements

Potential enhancements to consider:
- Development container with debugging tools
- Multi-stage builds for smaller runtime images
- CI/CD integration with GitHub Actions
- Docker registry for pre-built images
- Production-ready docker-compose configurations