#!/bin/bash
# Refs:
# - https://help.ubuntu.com/community/UbuntuStudio/UsbAudioDevices
# - https://opensource.com/article/18/5/you-dont-know-bash-intro-bash-arrays
# - https://askubuntu.com/questions/423300/live-usb-on-a-2-partition-usb-drive

here=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


# get sudo permission
echo "Can haz sudo?"
sudo echo "Thank you!"


# find USB storage devices
usb_all=$(
  lsblk --output name,vendor,model,size,tran | \
  grep ' usb$'
)

usb_hds=()
while read -r usb ; do
  device="/dev/$( echo "$usb" | awk '{print $1}' )"
  vendor=$( echo "$usb" | awk '{print $2}' )
  model=$( echo "$usb" | awk '{print $3}' )
  size=$( echo "$usb" | awk '{print $4}' )

  usb_hds+=( "$vendor"$'\t'"$model"$'\t'"$size"$'\t'"$device" )
done <<< "$usb_all"


# get user device selection
echo ""
echo "┏━━━━━━━━━━━━━━━━━━━━━┓"
echo -e "┃ \033[1mUSB Storage Devices\033[0m ┃"
echo "┗━━━━━━━━━━━━━━━━━━━━━┛"
for idx in "${!usb_hds[@]}" ; do
  hd="${usb_hds[idx]}"
  echo "$idx"$'\t'"$hd"
done
usb_max=$(( "${#usb_hds[@]}" - 1 ))

echo ""
read -p "Choose device to overwrite with Zarf Boots [0-$usb_max]: " selected_idx
is_an_integer='?(-)+([[:digit:]])'
if [[ "$selected_idx" != $is_an_integer ]] ; then
  echo "No good -- I need a number!"
  exit 1
fi
if (( "$selected_idx" < 0 || "$selected_idx" > $usb_max )) ; then
  echo "No good -- I don't have a device at index $selected_idx!"
  exit 1
fi


# confirm user device selection
echo ""
echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo -e "┃ \033[1mSelected Storage Device\033[0m ┃"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━┛"
selected_dev=$( echo "${usb_hds[selected_idx]}" | awk '{print $4}' )
selected_parted=$( sudo parted "$selected_dev" print )
echo "$selected_parted"
echo ""
read -p "Warning! This is a destructive operation. Are you sure? [y/N] " choice
case "$choice" in
  y|Y ) ;;
  * ) exit 1;;
esac


# write usb.img to selected USB
USB_IMG="$here/.loop_usb/usb.img"
BLOCK=$( numfmt --from=iec-i 4Ki )
sudo dd if="$USB_IMG" of="$selected_dev" bs="$BLOCK" conv=sparse oflag=direct status=progress