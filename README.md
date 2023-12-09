
# CUDASWAP: CUDA SWitching and Activation Program

## Overview
CUDASWAP is a Bash utility designed to simplify the management of different NVIDIA CUDA versions on a Linux system. It provides an easy way to switch between installed CUDA versions, install new ones, and ensure that the correct version is activated for development and runtime environments.

## Purpose
CUDASWAP was created to address the challenge of working with multiple projects that may require different versions of CUDA. It enables developers to easily switch between CUDA versions without manually manipulating environment variables or installing and uninstalling different versions.

## Features
- **Version Switching**: Quickly switch between different installed CUDA versions.
- **Automatic Installation**: Offers to install a specified version of CUDA if it's not already installed.
- **Version Verification**: Confirms that the correct version of CUDA is active by checking the version of the NVIDIA CUDA Compiler (`nvcc`).
- **Environment Variable Management**: Automatically sets the `PATH` and `LD_LIBRARY_PATH` environment variables to match the selected CUDA version.
- **Backup and Restore**: Backs up the original `PATH` and `LD_LIBRARY_PATH` before modification and restores them when switching versions.
- **Interactive User Interface**: Provides a simple and interactive user interface for installing new versions and switching between them.

## Usage

### Adding CUDASWAP to Your Environment
To use CUDASWAP, you can either source it directly in your shell or include it in your `.bashrc` file for automatic loading in every new shell session.

#### Option 1: Sourcing Directly
Run the following command in your terminal:
```bash
source /path/to/cudaswap.sh
```

#### Option 2: Adding to `.bashrc`
Add the following line to your `.bashrc` file:
```bash
source /path/to/cudaswap.sh
```
After adding it, either restart your terminal or source your `.bashrc` file:
```bash
source ~/.bashrc
```

### Running CUDASWAP
- To switch to a specific version of CUDA (e.g., version 11.0), simply run:
  ```bash
  cudaswap 11.0
  ```
- To switch to the default/latest version of CUDA, run:
  ```bash
  cudaswap
  ```
- If the specified version is not installed, CUDASWAP will prompt you to install it.

## Installation Instructions
1. Place `cudaswap.sh` in a directory where you keep scripts, such as `~/bin` or `~/scripts`.
2. Ensure that the script is executable:
   ```bash
   chmod +x ~/scripts/cudaswap.sh
   ```
3. Follow the usage instructions above to add CUDASWAP to your environment.

## Notes on Path Modifications
When using CUDASWAP, it's recommended to remove other CUDA path modifications from your `.bashrc` or other shell initialization files. CUDASWAP manages the `PATH` and `LD_LIBRARY_PATH` environment variables for CUDA, and having other modifications can lead to conflicts or unexpected behaviors.

## Why CUDASWAP?
CUDASWAP was developed to streamline the workflow for developers working with CUDA-dependent projects, especially when these projects require different versions of CUDA. It automates the tedious tasks of installing, activating, and verifying CUDA versions, thus saving time and reducing the potential for manual errors.

## System Requirements
- Bash shell environment
- NVIDIA CUDA toolkit
- Access to `sudo` for installing CUDA packages (Debian-based systems)

## Contributions
Feedback and contributions to CUDASWAP are welcome. Feel free to fork, modify, and submit pull requests or open issues for suggestions and enhancements.

---
Created by Richard Graver

