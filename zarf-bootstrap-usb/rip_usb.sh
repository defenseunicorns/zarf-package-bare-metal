#!/bin/bash
# Reqs:
# - run as root (i.e. sudo)

# find usb drive device
# USB_DEVICE=$()
USB_DEVICE="/dev/sda"
USB_DATA="${USB_DEVICE}4"

# set output dir
DL="./.downloads"

# umount any partitions on usb device
mounts=$( mount | grep "$USB_DEVICE" | awk '{print $1}' )
if [ -n "$mounts" ] ; then
  echo "$mounts" | xargs umount
fi

# zero-out free space on usb data partition
# https://askubuntu.com/questions/1369131/using-dd-with-conv-sparse-for-creating-partition-or-full-disk-images
# zerofree "$USB_DATA" # <-- takes SOOO LOONNNGGGG on 16GB USB 2 drive
#   ^-- maybe try again later / or after ripping to disk..?

# save image of usb
# dd if="$USB_DEVICE" of="${DL}/usb.iso" bs=1M oflag=direct status=progress conv=sparse
dd if="$USB_DEVICE" of="${DL}/usb.img" bs=1M oflag=direct status=progress