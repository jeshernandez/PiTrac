---
layout: default
title: Testing Framework
parent: Development Guide
nav_order: 6
---

# PiTrac Testing Framework

This guide documents the actual testing infrastructure available in PiTrac, based on the current codebase implementation.

## Testing Overview

PiTrac uses multiple testing approaches:
- **Boost Test Framework** for C++ unit tests
- **CMake/CTest** for test compilation and execution  
- **Bash scripts** for hardware and system testing
- **GitHub Actions** for continuous integration
- **CLI commands** via the `pitrac` tool for manual testing

## C++ Unit Tests

### Test Framework

PiTrac uses the **Boost Test Framework** (not Google Test) for C++ unit testing.

### Test Locations

Tests are located in module-specific directories:
- `Software/LMSourceCode/ImageProcessing/Camera/tests/`
- `Software/LMSourceCode/ImageProcessing/ImageAnalysis/tests/`

### Building and Running Tests

Tests are built using CMake (not Meson for test modules):

```bash
# Build tests on Windows (PowerShell)
cd Software/LMSourceCode/ImageProcessing
./build_tests.ps1

# Or manually with CMake
cd Camera
mkdir build && cd build
cmake ..
make
ctest
```

### Approval Testing

The ImageAnalysis module uses an approval testing framework for validating image processing results against known good outputs.

## PiTrac CLI Test Commands

The `pitrac` CLI tool provides several test commands:

### Hardware Testing
```bash
# Test hardware components (Pi model, GPIO, cameras, services)
pitrac test hardware

# Test strobe pulse timing
pitrac test pulse

# Test camera functionality
pitrac test camera
```

### Software Testing
```bash
# Quick image processing test without cameras
pitrac test quick

# Spin detection test
pitrac test spin

# Full automated test suite
pitrac test automated
```

### Simulator Testing
```bash
# Test GSPro simulator connection
pitrac test gspro
```

## Hardware Test Implementation

The main hardware test script is located at `packaging/src/test/hardware.sh` and validates:
- Raspberry Pi model detection
- Camera availability
- GPIO chip detection
- Service status (ActiveMQ, TomEE, PiTrac)

Example test functions from the actual script:

```bash
test_pi() {
    if [[ ! -f /proc/device-tree/model ]]; then
        echo "❌ Not running on Raspberry Pi"
        return 1
    fi
    # ... rest of implementation
}

test_cameras() {
    local cmd camera_count
    # Uses rpicam-hello for Pi 5, libcamera-hello for Pi 4
    # ... implementation
}
```

## Test Images

Test images are provided in:
- `/usr/share/pitrac/test-images/` (when installed via package)
- `packaging/build/package/debian/usr/share/pitrac/test-images/` (in source)

Available test images:
- `teed-ball.png` - Golf ball on tee
- `strobed.png` - Strobed ball capture

## Continuous Integration

### GitHub Actions Workflows

PiTrac uses GitHub Actions for CI, with workflows located in `.github/workflows/`:

#### Camera Tests (`camera-tests.yml`)
- **Runs on**: `windows-latest`
- **Build System**: CMake
- **Dependencies**: OpenCV, Boost (via vcpkg)
- **Test Command**: `ctest -C Debug`

#### Image Analysis Tests (`image-analysis-tests.yml`)
- **Runs on**: `windows-latest`  
- **Build System**: CMake
- **Dependencies**: OpenCV, Boost
- **Test Command**: `ctest -C Debug`

Example workflow structure:
```yaml
name: Camera Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install dependencies
        run: vcpkg install opencv4 boost-test
      - name: Build and test
        run: |
          cd Software/LMSourceCode/ImageProcessing/Camera
          mkdir build && cd build
          cmake ..
          cmake --build . --config Debug
          ctest -C Debug
```

## Running Tests Locally

### Prerequisites
- Boost Test library (>= 1.74)
- OpenCV (>= 4.9.0)
- CMake (for test builds)
- Meson/Ninja (for main application)

### Quick Test Execution

```bash
# Run hardware tests on Pi
pitrac test hardware

# Run quick software test
pitrac test quick

# Run all automated tests
pitrac test automated
```

### Building C++ Tests

```bash
# Camera module tests
cd Software/LMSourceCode/ImageProcessing/Camera
mkdir build && cd build
cmake ..
make
ctest

# Image Analysis tests  
cd Software/LMSourceCode/ImageProcessing/ImageAnalysis
mkdir build && cd build
cmake ..
make
ctest
```

## Test Coverage

Currently, PiTrac does not have coverage reporting configured. The following tools are **not** currently integrated:
- gcovr
- codecov
- Coverage reports in CI

## Known Limitations

1. **No Python test framework** - Despite Python utilities existing, no pytest or similar framework is configured
2. **No integration tests** - No automated message broker or simulator integration tests
3. **No E2E test suite** - End-to-end testing must be done manually
4. **Limited test data** - Only 2 test images provided
5. **No coverage tracking** - Test coverage is not measured or reported
6. **Windows-only CI** - GitHub Actions only test on Windows, not on actual Pi hardware

## Adding New Tests

### C++ Tests with Boost

Create new test files following the existing pattern:

```cpp
#define BOOST_TEST_MODULE MyTestModule
#include <boost/test/included/unit_test.hpp>

BOOST_AUTO_TEST_CASE(test_something) {
    BOOST_CHECK_EQUAL(1 + 1, 2);
}
```

### Bash Test Scripts

Add test functions to `packaging/src/test/hardware.sh` or create new scripts following the pattern:

```bash
test_new_feature() {
    echo -n "Testing new feature... "
    # Test implementation
    if [[ condition ]]; then
        echo "✅ PASSED"
        return 0
    else
        echo "❌ FAILED"
        return 1
    fi
}
```

## Summary

The PiTrac testing framework provides basic unit testing via Boost Test, hardware validation through bash scripts, and manual testing via CLI commands. While not as comprehensive as initially documented, it covers essential functionality for development and validation.

For production deployment, thorough manual testing on actual Raspberry Pi hardware is recommended, as CI only runs on Windows environments.