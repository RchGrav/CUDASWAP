
# CUDASWAP: CUDA Switching and Activation Program

## Overview
CUDASWAP is a Bash utility designed to simplify the management of different NVIDIA CUDA versions on Linux systems. It offers an easy way to switch between installed CUDA versions, install new ones, and ensure the correct version is activated for development and runtime environments.

## Purpose
CUDASWAP addresses the challenge of working with multiple projects that may require different versions of CUDA. It enables developers to switch between CUDA versions effortlessly without manual manipulation of environment variables or the need to install and uninstall different versions.

## Features
- **Version Switching**: Seamlessly switch between different installed CUDA versions.
- **Automatic Installation**: Installs a specified version of CUDA if not already present.
- **Version Verification**: Verifies the active CUDA version using the NVIDIA CUDA Compiler (`nvcc`).
- **Environment Variable Management**: Automatically sets `PATH` and `LD_LIBRARY_PATH` to match the selected CUDA version.
- **Backup and Restore**: Backs up and restores the original `PATH` and `LD_LIBRARY_PATH` during version switches.
- **Interactive User Interface**: Provides a user-friendly interface for installing and switching between CUDA versions.

## Usage

### Adding CUDASWAP to Your Environment
To use CUDASWAP, source it in your shell or include it in your `.bashrc` for automatic loading.

#### Option 1: Sourcing Directly
```bash
source /path/to/cudaswap.sh
```

#### Option 2: Adding to `.bashrc`
```bash
echo 'source ~/scripts/cudaswap.sh' >> ~/.bashrc
source ~/.bashrc
```

### Running CUDASWAP
- To switch to a specific CUDA version (e.g., 11.0):
  ```bash
  cudaswap 11.0
  ```
- To switch to the default/latest CUDA version:
  ```bash
  cudaswap
  ```

## Installation Instructions
1. Place `cudaswap.sh` in the `scripts` folder within your home directory. If the folder doesn't exist, create it:
   ```bash
   mkdir -p ~/scripts
   cp cudaswap.sh ~/scripts/
   ```
2. Add CUDASWAP to your environment as described in the Usage section.

## Notes on Path Modifications
To ensure CUDASWAP functions correctly, remove any other CUDA-related path modifications from your `.bashrc` or other shell initialization files.

## System Requirements
- Bash shell environment
- NVIDIA CUDA toolkit
- Access to `sudo` for installing CUDA packages (Debian-based systems)

## Contributions
Feedback and contributions are welcome. Feel free to fork, modify, and submit pull requests or open issues for suggestions and enhancements.

---
Created by Richard Graver
