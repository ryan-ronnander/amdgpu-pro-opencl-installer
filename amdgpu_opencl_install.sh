#!/bin/bash
# This script is adapted from the 'opencl-amd' Arch Linux package: https://aur.archlinux.org/packages/opencl-amd/
# Install proprietary opencl components only!! - Run as root
# If amdgpu-pro stack is installed, completely purge it from system first by:
# 1) running 'amdgpu-pro-uninstall'
# 2) removing amdgpu-pro directory remnants 'rm -rf /opt/amdgpu*'
# 3) reboot

# Set packaging variables
pkgname='opencl-amd'
prefix='amdgpu-pro-'
major='17.50'
minor='511655'
arch='x86_64'
platform='el7'

srcdir=~/${pkgname}

mkdir -p $srcdir
cd ${srcdir}

referer="http://support.amd.com/en-us/kb-articles/Pages/Radeon-Software-for-Linux-Release-Notes.aspx"
download="https://www2.ati.com/drivers/linux/rhel7/${prefix}${major}-${minor}.tar.xz"

# Remove previous downloads if they exist
rm -rf ${prefix}${major}-${minor}.tar.xz
rm -rf ${prefix}${major}-${minor}

# Download amdgpu-pro RHEL7 package from AMD's driver page
wget ${download} --referer ${referer}

# Extract package
tar -xvf ${prefix}${major}-${minor}.tar.xz

# Change 'libdrm_amdgpu' references to 'libdrm_amdgpo' - Required workaround
mkdir -p "${srcdir}/opencl"
cd "${srcdir}/opencl"
rpm2cpio "${srcdir}/${prefix}${major}-${minor}/RPMS/${arch}/libopencl-amdgpu-pro-icd-${major}-${minor}.${platform}.${arch}.rpm" | cpio -idmv
cd opt/amdgpu-pro/lib64
sed -i "s|libdrm_amdgpu|libdrm_amdgpo|g" libamdocl64.so

# Rename libraries to reflect the 'amdgpo' rename
mkdir -p "${srcdir}/libdrm"
cd "${srcdir}/libdrm"
rpm2cpio "${srcdir}/${prefix}${major}-${minor}/RPMS/${arch}/libdrm-amdgpu-2.4.82-${minor}.${platform}.${arch}.rpm"  | cpio -idmv
cd opt/amdgpu/lib64/
rm -f "libdrm_amdgpu.so.1"
mv -f "libdrm_amdgpu.so.1.0.0" "libdrm_amdgpo.so.1.0.0"
ln -s "libdrm_amdgpo.so.1.0.0" "libdrm_amdgpo.so.1"

# Copy OpenCL icd file
mkdir -p /etc/OpenCL/vendors/
mv -f "${srcdir}/opencl/etc/OpenCL/vendors/amdocl64.icd" /etc/OpenCL/vendors/

# Copy libraries
/bin/cp -f "${srcdir}/opencl/opt/amdgpu-pro/lib64/libamdocl64.so" "/usr/lib64/"
/bin/cp -f "${srcdir}/opencl/opt/amdgpu-pro/lib64/libamdocl12cl64.so" "/usr/lib64/"
/bin/cp -f "${srcdir}/libdrm/opt/amdgpu/lib64/libdrm_amdgpo.so.1.0.0" "/usr/lib64/"
/bin/cp -f "${srcdir}/libdrm/opt/amdgpu/lib64/libdrm_amdgpo.so.1" "/usr/lib64/"

# link .ids file
mkdir -p "/opt/amdgpu/share/libdrm"
cd "/opt/amdgpu/share/libdrm"
rm -f amdgpu.ids
ln -s /usr/share/libdrm/amdgpu.ids amdgpu.ids

# Cleanup
rm -rf "${srcdir}/opencl"
rm -rf "${srcdir}/libdrm"

# rm -rf ${srcdir} # optional - clean up entire download
