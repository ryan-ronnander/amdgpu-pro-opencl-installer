# amdgpu-pro-opencl-installer
AMD OpenCL installer scripts for Linux. These scripts install AMD's "legacy" (non-ROCm) OpenCL components alongside the open source amdgpu stack. These scripts are adapted for OpenSUSE and Fedora from the 'opencl-amd' Arch Linux package: https://aur.archlinux.org/packages/opencl-amd/. 

**For GPUs older than Polaris (RX 460, RX 470, RX 480):**

If you're using the 'radeon' kernel module (default for 7900 series, 200 series, 300 series GPUs), you will need to blacklist the radeon module and add extra kernel parameters to your grub defaults. The 'amdgpu' kernel module is required to run the OpenCL components. 

Kernel >= 4.15 recommended. 
