#!/bin/bash
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script should be sourced, not executed. Run 'source ${0}'"
    exit 1
fi

check_and_elevate_privileges() {
    if [[ $(id -u) -ne 0 ]]; then
        echo "Script not running as root. Attempting to elevate privileges..."
        exec sudo "$0" "$@"
        exit $?
    else
        echo "Running with superuser privileges."
    fi
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
    check_and_elevate_privileges
    check_os_and_arch

    local base64_key="VG/EnpimZPOblEJ1OpibJJCXLrbn+qcJ8JNuGTSK6v2aLBmhR8VR/aSJpmkg7fFjcGklweTI8+Ibj72HuY9JRD/+dtUoSh7z037mWo56ee02lPFRD0pHOEAlLSXxFO/SDqRVMhcgHk0a8roCF+9h5Ni7ZUyxlGK/uHkqN7ED/U/ATpGKgvk4t23eTpdRC8FXAlBZQyf/xnhQXsyF/z7+RV5CL0o1zk1LKgo+5K325ka5uZb6JSIrEPUaCPEMXu6EEY8zSFnCrRS/Vjkfvc9ViYZWzJ387WTjAhMdS7wdPmdDWw2ASGUP4FrfCireSZiFX+ZAOspKpZdh0P5iR5XSx14XDt3jNK2EQQboaJADuqksItatOEYNu4JsCbc24roJvJtGhpjTnq1/dyoy6K433afU0DS2ZPLthLpGqeyKMKNY7a2WjxhRmCSu5Zok/fGKcO62XF8a3eSj4NzCRv8LM6mG1Oekz6Zz+tdxHg19ufHO0et7AKE5q+5VjE438Xpl4UWbM/Voj6VPJ9uzywDcnZXpeOqeTQh2pQARAQABtCBjdWRhdG9vbHMgPGN1ZGF0b29sc0BudmlkaWEuY29tPokCOQQTAQIAIwUCYliaUQIbAwcLCQgHAwIBBhUIAgkKCwQWAgMBAh4BAheAAAoJEKS0aZY7+GPM1y4QALKhBqSozrYbe341Qu7SyxHQgjRCGi4YhI3bHCMj5F6vEOHnwiFH6YmFkxCYtqcGjca6iw7cCYMow/hgKLAPwkwSJ84EYpGLWx62+20rMM4OuZwauSUcY/kE2WgnQ74zbh3+MHs56zntJFfJ9G+NYidvwDWeZn5HIzR4CtxaxRgpiykg0s3ps6X0U+vuVcLnutBF7r81astvlVQERFbce/6KqHK+yj843Qrhb3JEolUoOETK06nD25bVtnAxe0QEyA909MpRNLfR6BdjPpxqhphDcMOhJfyubAroQUxG/7S+Yw+mtEqHrL/dz9iEYqodYiSozfi0b+HFI59sRkTfOBDBwb3kcARExwnvLJmqijiVqWkoJ3H67oA0XJN2nelucw+AHb+Jt9BWjyzKWlLFDnVHdGicyRJ0I8yqi32w8hGeXmu3tU58VWJrkXEXadBftmcipemb6oZ/r5SCkW6kxr2PsNWcJoebUdynyOQGbVwpMtJAnjOYp0ObKOANbcIg+tsikyCIO5TiY3ADbBDPCeZK8xdcugXoW5WFwACGC0z+Cn0mtw8z3VGIPAMSCYmLusgWt2+EpikwrP2inNp5Pc+YdczRAsa4s30Jpyv/UHEG5P9GKnvofaxJgnU56lJIRPzFiCUGy6cVI0Fq777X/ME1K6A/bzZ4vRYNx8rUmVE5"

    local keyring_path="/usr/share/keyrings/cuda-archive-keyring.gpg"
    local sources_list_d="deb [signed-by=$keyring_path] https://developer.download.nvidia.com/compute/cuda/repos/$ID$VRSN/$ARCH/ /"
    local sources_list_d_path="/etc/apt/sources.list.d/cuda-$ID$VRSN-$ARCH.list"
    local preferences_d="Package: nsight-compute\nPin: origin *ubuntu.com*\nPin-Priority: -1\n\nPackage: nsight-systems\nPin: origin *ubuntu.com*\nPin-Priority: -1\n\nPackage: *\nPin: release l=NVIDIA CUDA\nPin-Priority: 600"
    local preferences_d_path="/etc/apt/preferences.d/cuda-repository-pin-600"

    printf "$base64_key" | base64 --decode > "$keyring_path"
    echo "$sources_list_d" > "$sources_list_d_path"
    echo "$preferences_d" > "$preferences_d_path"

    if [[ -f "$keyring_path" ]]; then
        echo "CUDA keyring installed successfully."
    else
        echo "Failed to install CUDA keyring."
        return 1
    fi
}

install_cuda_toolkit() {
    if ! apt-get install -y "$1"; then
        echo "The package $1 does not exist or failed to install."
        
        if ! grep -q "^deb .*developer.download.nvidia.com/compute/cuda/repos" /etc/apt/sources.list.d/*; then
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
            echo "CUDA repository is already installed, but the package $1 could not be installed."
            return 1
        fi
    else
        echo "The package $1 was installed successfully."
    fi
}

function cuda() {
    check_and_elevate_privileges
    check_os_and_arch

    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" || "$ID_LIKE" == "debian" ]]; then
            [[ -z "${LD_LIBRARY_PATH_CUDA_BACKUP}" ]] && export LD_LIBRARY_PATH_CUDA_BACKUP=$LD_LIBRARY_PATH
            [[ -z "${PATH_CUDA_BACKUP}" ]] && export PATH_CUDA_BACKUP=$PATH

            local cuda_folder="/usr/local/cuda"
            local package_name="cuda"
            if [ -n "$1" ]; then
                cuda_folder="/usr/local/cuda-$1"
                package_name="cuda-toolkit-${1//./-}"
            fi
            local cuda_bin_path="$cuda_folder/bin"
            local cuda_lib_path="$cuda_folder/lib64"

            if [ ! -d "$cuda_bin_path" ] || [ ! -d "$cuda_lib_path" ]; then
                read -p "Do you want to try to install NVIDIA CUDA $1? [Y/N]:" -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    apt-get update -y
                    install_cuda_toolkit "$package_name"
                else
                    echo "CUDA installation was skipped."
                    return 1
                fi
            fi

            export PATH=$cuda_bin_path:$PATH_CUDA_BACKUP
            export LD_LIBRARY_PATH=$cuda_lib_path:$LD_LIBRARY_PATH_CUDA_BACKUP

            local nvcc_version=$(nvcc --version | grep release | awk '{print $6}' | cut -d ',' -f1 | sed 's/V//')
            if [ -z "$1" ] || [[ "$nvcc_version" == *"$1"* ]]; then
                echo "NVIDIA CUDA version $nvcc_version is now active."
            else
                echo "Warning: Active CUDA version ($nvcc_version) does not match the requested version ($1)."
            fi
        fi
    else
        echo "Cannot determine the operating system."
        exit 1
    fi
}
