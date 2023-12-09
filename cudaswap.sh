#!/bin/bash
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script should be sourced, not executed. Run 'source ${0}'"
    exit 1
fi

function cudaswap() {
	if [[ -f /etc/os-release ]]; then
		. /etc/os-release
		if [[ "$ID" == "ubuntu" || "$ID_LIKE" == "debian" ]]; then
			# Backup the original PATH and LD_LIBRARY_PATH if not already backed up
			[[ -z "${LD_LIBRARY_PATH_CUDA_BACKUP}" ]] && export LD_LIBRARY_PATH_CUDA_BACKUP=$LD_LIBRARY_PATH
			[[ -z "${PATH_CUDA_BACKUP}" ]] && export PATH_CUDA_BACKUP=$PATH

			# Determine the CUDA folder and package name
			cuda_folder="/usr/local/cuda"
			package_name="cuda"
			if [ -n "$1" ]; then
				cuda_folder="/usr/local/cuda-$1"
				package_name="cuda-toolkit-${1//./-}"
			fi
			cuda_bin_path="$cuda_folder/bin"
			cuda_lib_path="$cuda_folder/lib64"

			# Check if the CUDA paths exist or attempt installation
			if [ ! -d "$cuda_bin_path" ] || [ ! -d "$cuda_lib_path" ]; then
				# Offer to install CUDA
				read -p "Do you want to try to install NVIDIA CUDA $1? [Y/N]:" -n 1 -r
				echo    # (optional) move to a new line
				if [[ $REPLY =~ ^[Yy]$ ]]; then
					sudo apt install $package_name
					if [ $? -ne 0 ]; then
						echo "The package $package_name does not exist or failed to install."
						return 1
					fi
					echo "The package $package_name was installed successfully."
				else
					echo "CUDA installation was skipped."
					return 1
				fi
			fi

			# Set the PATH and LD_LIBRARY_PATH
			export PATH=$cuda_bin_path:$PATH_CUDA_BACKUP
			export LD_LIBRARY_PATH=$cuda_lib_path:$LD_LIBRARY_PATH_CUDA_BACKUP

			# Check the version of nvcc
			nvcc_version=$(nvcc --version | grep release | awk '{print $6}' | cut -d ',' -f1 | sed 's/V//')
			if [ -z "$1" ] || [[ "$nvcc_version" == *"$1"* ]]; then
				echo "NVIDIA CUDA version $nvcc_version is now active."
			else
				echo "Warning: Active CUDA version ($nvcc_version) does not match the requested version ($1)."
			fi
        else
            echo "This function is intended for Ubuntu or Debian systems."
            exit 1
        fi
    else
        echo "Cannot determine the operating system."
        exit 1
    fi
}
