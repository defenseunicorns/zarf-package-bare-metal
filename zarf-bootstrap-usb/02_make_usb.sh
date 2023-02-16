#!/bin/bash
# Reqs:
# - run as root (i.e. sudo)
# 
# Refs:
# - https://askubuntu.com/questions/423300/live-usb-on-a-2-partition-usb-drive

# find usb drive device
# USB_DEVICE=$()
USB_DEVICE="/dev/sda"

# get user approval to use the drive
while true; do
  echo ""
  fdisk --list "$USB_DEVICE"
  echo ""
  udevadm info --query=all -n "$USB_DEVICE" | grep -P 'DEVPATH='
  echo ""

  read -p "You're about to wipe ${USB_DEVICE}!  Is that okay? [y/N] " answer
  case $answer in
    [Yy]* ) echo "" ; break ;;
    * ) echo "" ; exit 1 ;;
  esac
done

# umount any partitions on that device
mounts=$( mount | grep "$USB_DEVICE" | awk '{print $1}' )
if [ -n "$mounts" ] ; then
  echo "$mounts" | xargs umount
fi

# wipe gpt-based disk
# https://serverfault.com/a/787210
dd if=/dev/zero of=$USB_DEVICE bs=512 count=34
dd if=/dev/zero of=$USB_DEVICE bs=512 count=34 seek=$((`blockdev --getsz $USB_DEVICE` - 34))

# find mod'ed iso
iso="./.mod_iso/zarf-boots.iso"

# write iso to USB
dd if="$iso" of="$USB_DEVICE" bs=1M oflag=direct status=progress

# expand GPT to fill entire USB
# https://community.tenable.com/s/article/Unable-to-satisfy-all-constraints-on-the-partition-when-expanding-Tenable-Core-disk
# https://unix.stackexchange.com/questions/317564/expanding-a-disk-with-a-gpt-table
sgdisk --move-second-header "$USB_DEVICE"

# add data partition to usb (filling available space)
last_sector=$(
  parted /dev/sda 'unit s print' \
    | grep '^ 3' | awk '{ print $3}' \
    | sed 's/s//' )

# Warning: The resulting partition is not properly aligned for best performance:
# 2880548s % 2048s != 0s
block_boundary=$(( "$last_sector" - ( "$last_sector" % 2048 ) ))
next_sector=$(( "$block_boundary" + 2048 ))

parted --align optimal "$USB_DEVICE" mkpart primary ext4 "$next_sector"s 100%
e2label "${USB_DEVICE}4" "zarf-boots"
