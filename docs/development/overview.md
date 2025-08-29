---
layout: default
title: System Overview
parent: Development Guide
nav_order: 1
---

# PiTrac System Overview

Understanding PiTrac's architecture is essential for effective development. This document provides a comprehensive overview of the system's components, their interactions, and the design decisions that shape the project.

## System Architecture

PiTrac is a sophisticated real-time computer vision system that transforms a Raspberry Pi into a professional golf launch monitor. The architecture balances performance requirements with hardware limitations through careful design choices.

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    User Interface Layer                  │
│  ┌──────────┐  ┌─────────────┐  ┌──────────────────┐   │
│  │ CLI Tool │  │ Web Monitor │  │ Simulator Client │   │
│  └─────┬────┘  └──────┬──────┘  └────────┬─────────┘   │
│        └───────────────┼──────────────────┘             │
└────────────────────────┼────────────────────────────────┘
                         │
┌────────────────────────┼────────────────────────────────┐
│                 Service Layer                            │
│  ┌──────────────────────▼─────────────────────────┐     │
│  │           Message Broker (ActiveMQ)            │     │
│  └──────┬───────────┬──────────────┬──────────────┘     │
│         │           │              │                     │
│  ┌──────▼────┐ ┌───▼──────┐ ┌────▼────────┐           │
│  │  PiTrac   │ │  TomEE   │ │  Simulator  │           │
│  │  Core LM  │ │  Server  │ │  Interface  │           │
│  └──────┬────┘ └──────────┘ └─────────────┘           │
└─────────┼───────────────────────────────────────────────┘
          │
┌─────────▼───────────────────────────────────────────────┐
│                   Hardware Layer                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  Camera 1   │  │  Camera 2   │  │ GPIO/Strobe │     │
│  │  (Global    │  │  (Global    │  │   Control   │     │
│  │   Shutter)  │  │   Shutter)  │  │   (lgpio)   │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
```

### Core Components

#### PiTrac Launch Monitor Core (`pitrac_lm`)

The heart of the system, written in C++20 for maximum performance:

- **Image Acquisition**: Interfaces with Pi cameras through libcamera
- **Ball Detection**: Real-time computer vision using OpenCV
- **Physics Calculation**: 3D trajectory computation from stereo images
- **Message Publishing**: Sends results via ActiveMQ

Key source files:
- `ball_image_proc.cpp` - Main image processing pipeline (includes spin detection)
- `gs_fsm.cpp` - Finite state machine for shot detection
- `pulse_strobe.cpp` - Hardware strobe synchronization

#### Configuration Management System

A hierarchical system that provides flexibility while maintaining backward compatibility:

- **ConfigurationManager** - Central singleton managing all configuration
- **Parameter Mapping** - Translates user-friendly names to technical parameters
- **Multi-source Loading** - CLI → YAML → JSON precedence
- **Validation Engine** - Type checking and range validation

Key files:
- `configuration_manager.cpp/h` - Core configuration logic
- `gs_config.cpp/h` - Legacy configuration adapter
- `parameter-mappings.yaml` - User to technical parameter mapping
- `pitrac.yaml` - User configuration template

#### Message Broker (ActiveMQ)

Provides loose coupling between components:

- **Asynchronous Communication** - Components don't block each other
- **Topic-based Routing** - Publishers and subscribers by topic
- **Reliability** - Message persistence and delivery guarantees
- **Scalability** - Can distribute across multiple machines

Topics used:
- `Golf.Sim` - All system messages (shots, status, commands)

#### Web Monitoring Interface (TomEE)

Java-based web application for system monitoring:

- **Real-time Display** - Shows current shot data and system status
- **Club Selection** - Switch between Driver/Putter modes
- **Debug Tools** - Current shot image viewer and log display
- **Note**: Shot history and configuration UI are not yet implemented

#### Simulator Interfaces

Translates PiTrac data for golf simulators:

- **E6 Connect** - TCP socket protocol (port 2483)
- **GSPro** - JSON over TCP protocol
- **Note**: TruGolf uses the E6 interface (no separate implementation)

Each interface handles:
- Protocol translation
- Network communication
- Error recovery
- Latency optimization

### Data Flow

Understanding how data moves through the system is crucial for development:

#### Shot Detection Flow

1. **Camera Trigger**
   - Ball enters detection zone
   - GPIO triggers both cameras simultaneously
   - IR strobes flash for motion freeze

2. **Image Capture**
   - Camera captures strobed IR image with mutiple ball positions
   - Images transferred to memory via CSI

3. **Image Processing**
   - Ball detection using YOLO or Hugh Circles
   - Spin detection from ball markings

4. **Physics Calculation**
   - Velocity computation from position delta
   - Launch angle and direction calculation
   - Spin axis and rate determination

5. **Result Publishing**
   - Package data in standard format
   - Publish to message broker
   - Log to debug files if enabled

6. **Simulator Transmission**
   - Subscribe to shot messages
   - Translate to simulator protocol
   - Send over network


#### Configuration Flow

1. **Startup Loading**
   - Load default JSON configuration
   - Load user YAML overrides
   - Apply environment variables
   - Process command-line arguments

2. **Runtime Access**
   - Component requests parameter
   - ConfigurationManager resolves value
   - Validation ensures type safety
   - Value returned to component

3. **Dynamic Updates**
   - Web UI changes setting
   - Validation checks new value
   - Configuration updated in memory
   - Components notified of change

### Hardware Abstraction

PiTrac abstracts hardware differences to support multiple Pi models:

#### Camera System
- **libcamera** - Modern camera stack (Pi OS Bookworm+)
- **Global Shutter Support** - Pi Camera v3 GS or equivalent
- **Hardware Sync** - GPIO triggering for simultaneity

#### GPIO Control
- **lgpio Library** - Modern GPIO interface
- **Chip Selection** - Automatic Pi4 (chip 0) vs Pi5 (chip 4)
- **SPI Communication** - High-speed strobe control
- **Interrupt Handling** - Low-latency ball detection

#### Platform Detection
```cpp
// Automatic platform detection via GetPiModel()
int gpio_chip = (GolfSimConfiguration::GetPiModel() == GolfSimConfiguration::PiModel::kRPi5) ? 4 : 0;
```

### Performance Optimizations

Meeting real-time requirements on limited hardware requires careful optimization:


#### Build Optimizations
- **Release Mode** - Uses Meson's `--buildtype=release` which applies `-O3` optimization
- **Standard Optimizations** - Compiler optimizations for release builds
- **Note**: Advanced optimizations (LTO, PGO, `-march=native`) are not currently enabled

#### System Tuning
- **CPU Governor** - Set to performance mode
- **Memory Split** - Optimize GPU/CPU memory allocation
- **Process Priority** - Real-time scheduling for core process
- **Network Tuning** - Optimize TCP settings for low latency

### Extensibility Points

The architecture provides some extension points with others planned:

#### Currently Implemented
- **Post-Processing Stages** - Working plugin system for image filters with 13+ stages
- **Image Analyzer Interface** - Framework for custom ball detection (OpenCV implemented)
- **Configuration Overrides** - YAML-based user configuration system

### Development Considerations

When developing PiTrac, keep these architectural principles in mind:

#### Separation of Concerns
Each component has a single, well-defined responsibility. Don't mix concerns like image processing with network communication.

#### Loose Coupling
Components communicate through well-defined interfaces (messages, configuration). Avoid direct dependencies between components.

#### Performance First
Every code change should consider performance impact. Profile before and after significant changes.

#### Hardware Awareness
Code should account for hardware variations (Pi4 vs Pi5, different cameras). Use abstraction layers for hardware-specific code.

#### User Experience
Features should be accessible to DIY builders. Avoid complexity that doesn't provide clear value.

### System Limitations

Understanding current limitations helps set realistic expectations:

#### Hardware Constraints
- **CPU Performance** - Pi4/5 processing power limits
- **Memory Bandwidth** - Image transfer bottlenecks
- **Network Latency** - Ethernet recommended over WiFi

#### Software Constraints
- **Calibration Required** - Manual camera alignment
- **Limited Club Data** - Ball-only tracking currently

#### Future Improvements
- **Club Tracking** - Add club head analysis
- **Outdoor Mode** - Compensate for ambient IR
- **AI Enhancement** - ML-based detection improvement

### Debugging and Troubleshooting

The architecture includes comprehensive debugging support:

#### Debug Modes
- **Image Logging** - Save processed frames for analysis
- **Message Tracing** - Log all message broker traffic
- **Performance Profiling** - Timing for each pipeline stage
- **State Dumping** - System state on error conditions

#### Debug Tools
- **CLI Testing** - `pitrac test` subcommands (hardware, pulse, quick, spin, gspro, automated, camera)
- **Log Analysis** - Structured logging with levels
- **Image Viewer** - Visualize processing steps
- **Network Monitor** - Track simulator communication

### Integration with External Systems

PiTrac is designed to integrate with various external systems:

#### Simulator Protocols
- **Network-based** - TCP/UDP protocols
- **File-based** - Shared file exchange
- **API-based** - REST/WebSocket interfaces

#### Home Automation
- **MQTT** - Publish shots to home automation
- **Webhooks** - HTTP callbacks on events
- **Database** - Store shots for analysis
- **Cloud** - Optional cloud synchronization

## Summary

PiTrac's architecture balances several competing demands: real-time performance on limited hardware, ease of use for DIY builders, flexibility for different setups, and reliability for consistent shot tracking. Understanding these architectural patterns and trade-offs is essential for contributing effectively to the project.

The modular design allows developers to work on specific components without deep knowledge of the entire system, while the message-based communication ensures changes in one area don't cascade throughout the codebase. This architecture has evolved through real-world use and continues to adapt as the project grows.