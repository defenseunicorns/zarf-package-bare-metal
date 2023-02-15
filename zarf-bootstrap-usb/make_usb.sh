#!/bin/bash
# Reqs:
# - run as root (i.e. sudo)
# 
# Refs:
# - https://askubuntu.com/questions/423300/live-usb-on-a-2-partition-usb-drive

# download Ubuntu 22.04 Server ISO
# https://releases.ubuntu.com/22.04.1/ubuntu-22.04.1-live-server-amd64.iso
# https://releases.ubuntu.com/22.04.1/SHA256SUMS

# find USB drive device
USB_DEVICE="/dev/sda"

# wipe USB drive
dd if=/dev/zero of="$USB_DEVICE" bs=512 count=1

# create new partitions
parted --align optimal "$USB_DEVICE" mklabel msdos
parted --align optimal "$USB_DEVICE" mkpart primary fat32 2048s 2GiB
parted --align optimal "$USB_DEVICE" mkpart primary ext4  2GiB  100%

# format partitions
mkfs.vfat -F 32 "${USB_DEVICE}1"
mkfs.ext4 -F "${USB_DEVICE}2"

# modify OS iso
cp ./.downloads/ubuntu-22.04.1-live-server-amd64.iso ./modified.iso
isohybrid --partok modified.iso

# write modified iso to USB
dd if=modified.iso of="${USB_DEVICE}1" bs=1M status=progress

# make USB iso partition bootable
parted "${USB_DEVICE}" set 1 boot on


# download any add'l deps