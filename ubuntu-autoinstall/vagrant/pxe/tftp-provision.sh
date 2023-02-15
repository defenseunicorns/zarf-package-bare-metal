#!/bin/bash

# Safer bash script
set -euxo pipefail

# Create tftpboot directory structure
mkdir -p /tftpboot/boot/bios/pxelinux.cfg
mkdir -p /tftpboot/boot/uefi/pxelinux.cfg
mkdir -p /tftpboot/grub/fonts
mkdir -p /tftpboot/init

chmod -R +w /tftpboot/

# Download Ubuntu 20 iso if it doesn't exist
if [ ! -f "ubuntu.iso" ]; then
  wget https://releases.ubuntu.com/22.04.1/ubuntu-22.04.1-live-server-amd64.iso -q -O ubuntu.iso
fi

# Mount Ubuntu iso
mkdir -p ubuntu-iso
if [ ! -f "ubuntu-iso/md5sum.txt" ]; then
  sudo mount -o loop ./ubuntu.iso ./ubuntu-iso/
else
  echo "Iso already mounted"
fi

# Install network boot dependencies
PACKAGES="pxelinux shim shim-signed grub-efi-amd64-signed grub-common"
sudo apt install -y $PACKAGES

# Copy pxe dependencies to proper directory for container usage
cp -p ./ubuntu-iso/casper/vmlinuz                            /tftpboot/init/
cp -p ./ubuntu-iso/casper/initrd                             /tftpboot/init/
cp -p /usr/lib/grub/x86_64-efi-signed/grubnetx64.efi.signed  /tftpboot/boot/uefi/grubx64.efi
cp -p /usr/lib/shim/shimx64.efi.signed                       /tftpboot/boot/uefi/bootx64.efi
cp -p /usr/share/grub/unicode.pf2                            /tftpboot/grub/fonts/
cp -p /vagrant/grub.cfg                                      /tftpboot/grub/grub.cfg