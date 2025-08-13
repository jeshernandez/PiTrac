# PiTrac Installation System

## What This Is
Hardened installation system for PiTrac that handles all dependencies with proper ordering, detection, and rollback. No more broken installs or dependency hell.

## What Changed
- **Proper dependency resolution** - installs things in the right order
- **Smart detection** - won't reinstall stuff that's already there
- **Rollback support** - can undo installations if something breaks
- **Better error handling** - actually tells you what went wrong
- **Installation tracking** - shows what's installed vs what's missing
- **Locking** - prevents multiple installs from stepping on each other

## Quick Start

1. Move this folder to your home directory: `mv Dev ~/`
2. Go into the folder: `cd ~/Dev` 
3. Make it executable: `chmod +x run.sh`
4. Run it: `./run.sh`

## What You'll See

The menu now shows installation status for each package:
- `[INSTALLED]` - package is ready to go
- `[NOT INSTALLED]` - needs to be installed

New menu options:
- **Install Software** - install individual packages or everything
- **Verify Installations** - check if stuff is working properly  
- **System Maintenance** - clean up, rollback, reset
- **View Logs** - see what happened during installs

## Behind the Scenes

### Smart Dependencies
The system knows what depends on what:
- ActiveMQ C++ won't install until ActiveMQ Broker is ready
- Everything installs in the right order automatically
- No more "missing dependency" errors

### What Gets Installed
- ActiveMQ Broker + C++ CMS (message queuing)
- OpenCV (computer vision)
- MessagePack (serialization)  
- LGPIO (GPIO control)
- Libcamera + RpiCam Apps (camera support)
- Java 17 + Maven (build tools)
- TomEE (application server)
- Boost libraries + PiTrac-specific packages

### Safety Features
- Locks prevent concurrent installations
- Logs everything for troubleshooting
- Can rollback if installs fail
- Verifies downloads before extracting
- Backs up existing installations before upgrading

## Troubleshooting

If something breaks:
1. Check **View Logs** menu for error details
2. Try **System Maintenance** → **Rollback Last Installation**  
3. Use **System Maintenance** → **Reset Installation State** as last resort

## For Developers

The dependency configuration is in `scripts/deps.conf`. Each install script has been cleaned up and standardized. The dependency resolver (`scripts/dep_resolver.sh`) can be used standalone:

```bash
# Install specific package
./scripts/dep_resolver.sh install opencv

# Check what's installed  
./scripts/dep_resolver.sh verify opencv

# See dependency order
./scripts/dep_resolver.sh deps opencv
```

