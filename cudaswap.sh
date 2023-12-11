#!/bin/bash
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script should be sourced, not executed. Run 'source ${0}'"
    exit 1
fi

# Function to display help information
show_help() {
    echo "Usage: cudaswap [version]"
    echo
    echo "This function switches between different installed versions of CUDA."
    echo "You need to specify the CUDA version in the format ## or ##.#"
    echo "Alternatively, use 'latest' to select the latest available version."
    echo
    echo "Examples:"
    echo "  cudaswap 11.0    # Switch to CUDA version 11.0"
    echo "  cudaswap latest  # Switch to the latest installed CUDA version"
}

check_os_and_arch() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        ARCH=$(uname -m)

        if [[ "$ID" == "ubuntu" ]]; then
            VRSN="${VERSION_ID//./}"
            if [[ "$ARCH" == "x86_64" || "$ARCH" == "aarch64" ]]; then
                local arch_desc="x86_64 (Standard PC)"
                [[ "$ARCH" == "aarch64" ]] && arch_desc="aarch64 (Nvidia Jetson)"
                echo "Running on Ubuntu $VERSION_ID with architecture $ARCH ($arch_desc)."
            else
                echo "FATAL ERROR: This script is only tested on x86_64 (Standard PC) and aarch64 (Nvidia Jetson) Ubuntu based hosts." >&2
                exit 1
            fi
        else
            echo "FATAL ERROR: This script is only tested on Ubuntu based hosts." >&2
            exit 1
        fi
    else
        echo "FATAL ERROR: Unable to determine operating system." >&2
        exit 1
    fi
}

install_cuda_repo() {
    check_os_and_arch

    local base64_key="VG/EnpimZPOblEJ1OpibJJCXLrbn+qcJ8JNuGTSK6v2aLBmhR8VR/aSJpmkg7fFjcGklweTI8+Ibj72HuY9JRD/+dtUoSh7z037mWo56ee02lPFRD0pHOEAlLSXxFO/SDqRVMhcgHk0a8roCF+9h5Ni7ZUyxlGK/uHkqN7ED/U/ATpGKgvk4t23eTpdRC8FXAlBZQyf/xnhQXsyF/z7+RV5CL0o1zk1LKgo+5K325ka5uZb6JSIrEPUaCPEMXu6EEY8zSFnCrRS/Vjkfvc9ViYZWzJ387WTjAhMdS7wdPmdDWw2ASGUP4FrfCireSZiFX+ZAOspKpZdh0P5iR5XSx14XDt3jNK2EQQboaJADuqksItatOEYNu4JsCbc24roJvJtGhpjTnq1/dyoy6K433afU0DS2ZPLthLpGqeyKMKNY7a2WjxhRmCSu5Zok/fGKcO62XF8a3eSj4NzCRv8LM6mG1Oekz6Zz+tdxHg19ufHO0et7AKE5q+5VjE438Xpl4UWbM/Voj6VPJ9uzywDcnZXpeOqeTQh2pQARAQABtCBjdWRhdG9vbHMgPGN1ZGF0b29sc0BudmlkaWEuY29tPokCOQQTAQIAIwUCYliaUQIbAwcLCQgHAwIBBhUIAgkKCwQWAgMBAh4BAheAAAoJEKS0aZY7+GPM1y4QALKhBqSozrYbe341Qu7SyxHQgjRCGi4YhI3bHCMj5F6vEOHnwiFH6YmFkxCYtqcGjca6iw7cCYMow/hgKLAPwkwSJ84EYpGLWx62+20rMM4OuZwauSUcY/kE2WgnQ74zbh3+MHs56zntJFfJ9G+NYidvwDWeZn5HIzR4CtxaxRgpiykg0s3ps6X0U+vuVcLnutBF7r81astvlVQERFbce/6KqHK+yj843Qrhb3JEolUoOETK06nD25bVtnAxe0QEyA909MpRNLfR6BdjPpxqhphDcMOhJfyubAroQUxG/7S+Yw+mtEqHrL/dz9iEYqodYiSozfi0b+HFI59sRkTfOBDBwb3kcARExwnvLJmqijiVqWkoJ3H67oA0XJN2nelucw+AHb+Jt9BWjyzKWlLFDnVHdGicyRJ0I8yqi32w8hGeXmu3tU58VWJrkXEXadBftmcipemb6oZ/r5SCkW6kxr2PsNWcJoebUdynyOQGbVwpMtJAnjOYp0ObKOANbcIg+tsikyCIO5TiY3ADbBDPCeZK8xdcugXoW5WFwACGC0z+Cn0mtw8z3VGIPAMSCYmLusgWt2+EpikwrP2inNp5Pc+YdczRAsa4s30Jpyv/UHEG5P9GKnvofaxJgnU56lJIRPzFiCUGy6cVI0Fq777X/ME1K6A/bzZ4vRYNx8rUmVE5"

    local keyring_path="/usr/share/keyrings/cuda-archive-keyring.gpg"
    local sources_list_d="deb [signed-by=$keyring_path] https://developer.download.nvidia.com/compute/cuda/repos/$ID$VRSN/$ARCH/ /"
    local sources_list_d_path="/etc/apt/sources.list.d/cuda-$ID$VRSN-$ARCH.list"
    local preferences_d="Package: nsight-compute\nPin: origin *ubuntu.com*\nPin-Priority: -1\n\nPackage: nsight-systems\nPin: origin *ubuntu.com*\nPin-Priority: -1\n\nPackage: *\nPin: release l=NVIDIA CUDA\nPin-Priority: 600"
    local preferences_d_path="/etc/apt/preferences.d/cuda-repository-pin-600"

    echo "$base64_key" | base64 --decode | sudo tee "$keyring_path" > /dev/null
    echo "$sources_list_d" | sudo tee "$sources_list_d_path" > /dev/null
    echo "$preferences_d" | sudo tee "$preferences_d_path" > /dev/null

    if [[ -f "$keyring_path" ]]; then
        echo "CUDA keyring installed successfully."
    else
        echo "Failed to install CUDA keyring."
        return 1
    fi
}

install_cuda_toolkit() {
    local package_name="$1"

    if ! sudo apt-get install -y "$package_name"; then
        echo "The package $package_name does not exist or failed to install."
        
        if ! sudo grep -q "^deb .*developer.download.nvidia.com/compute/cuda/repos" /etc/apt/sources.list.d/*; then
            echo "CUDA repository is not installed. Would you like to install it? [Y/N]"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                install_cuda_repo
                echo "Repository installed. Trying to install the CUDA toolkit again."
                install_cuda_toolkit "$1"
            else
                echo "CUDA repository installation was skipped."
                return 1
            fi
        else
            echo "CUDA repository is already installed, but the package $package_name could not be installed."
            return 1
        fi
    else
        echo "The package $package_name was installed successfully."
    fi
}

function cudaswap() {
    check_os_and_arch

    if [[ -z "${LD_LIBRARY_PATH_CUDA_BACKUP}" ]]; then
        export LD_LIBRARY_PATH_CUDA_BACKUP=$LD_LIBRARY_PATH
    fi
    if [[ -z "${PATH_CUDA_BACKUP}" ]]; then
        export PATH_CUDA_BACKUP=$PATH
    fi

    if [[ $1 == "latest" ]]; then
        local cuda_folder="/usr/local/cuda"
        local package_name="cuda"
    elif [[ -n "$1" ]]; then
        local cuda_folder="/usr/local/cuda-$1"
        local package_name="cuda-toolkit-${1//./-}"
    else 
        show_help
    fi

    local cuda_bin_path="$cuda_folder/bin"
    local cuda_lib_path="$cuda_folder/lib64"

    if [[ ! -d "$cuda_bin_path" ]] || [[ ! -d "$cuda_lib_path" ]]; then
        read -p "Do you want to try to install NVIDIA CUDA (version $1)? [Y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo apt-get update -y
            install_cuda_toolkit "$package_name"
        else
            echo "CUDA installation was skipped."
            return 1
        fi
    fi

    export PATH=$cuda_bin_path:$PATH_CUDA_BACKUP
    export LD_LIBRARY_PATH=$cuda_lib_path:$LD_LIBRARY_PATH_CUDA_BACKUP

    if command -v nvcc > /dev/null; then
        local nvcc_version=$(nvcc --version | grep release | awk '{print $6}' | cut -d ',' -f1 | sed 's/V//')
        if [[ -z "$1" ]] || [[ "$nvcc_version" == *"$1"* ]]; then
            echo "NVIDIA CUDA version $nvcc_version is now active."
        else
            echo "Warning: Active CUDA version ($nvcc_version) does not match the requested version ($1)."
        fi
    else
        echo "nvcc command not found. Unable to verify CUDA version."
        return 1
    fi
}
