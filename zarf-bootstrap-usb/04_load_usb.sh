#!/bin/bash
# Reqs:
# - run as root (i.e. sudo)
# 
# Refs:
# - https://askubuntu.com/questions/423300/live-usb-on-a-2-partition-usb-drive

# find usb drive device
# USB_DEVICE=$()
USB_DEVICE="/dev/sda"

# umount any partitions on that device
mounts=$( mount | grep "$USB_DEVICE" | awk '{print $1}' )
if [ -n "$mounts" ] ; then
  echo "$mounts" | xargs umount
fi

# mount usb data directory
USB_DATA="/media/zarfboots"
mkdir -p "$USB_DATA"
partition=$(
  lsblk -o name,label | grep 'zarf-boots' \
    | awk '{print $1}' | grep -Po '[a-zA-Z0-9]*'
)
mount "/dev/$partition" "$USB_DATA"

# add deps to usb
DL=".downloads"
cp $DL/zarf* "$USB_DATA"
cp "./firstboot.sh" "$USB_DATA/firstboot.sh"
cp "./runonce.service" "$USB_DATA/runonce.service"

# force-write & release usb
echo "Syncing data to usb..."
sync -f "$USB_DATA"
umount "$USB_DATA"