#!/bin/bash
OUT="$1"
DEPS="$2"

ZARF_BOOTS_ISO="$OUT/../02_zarf-boots-iso/zarf-boots.iso"
ZARF_BIN="$( find "$DEPS/zarf" -name "zarf_*_amd64" )"
ZARF_INIT="$( find "$DEPS/zarf" -name "zarf-init-amd64-*.tar.zst" )"
ZARF_PXE_PKG="$( find "$OUT/../01_zarf-package-pxe-server" -name "zarf-package-*-amd64.tar.zst" )"


# define img / write block sizes (in bytes)
# https://www.gnu.org/software/coreutils/manual/html_node/numfmt-invocation.html
# https://askubuntu.com/questions/931581/flashing-ubuntu-iso-to-usb-stick-with-dd-recommended-block-size
# size="15631122432" # Cruzer USB bytes
size=$( numfmt --from=iec-i 14.5Gi )
block=$( numfmt --from=iec-i 4Ki )
if [ $(( $size % $block )) -ne 0 ] ; then
  echo "Block ($block) doesn't divide evenly into size ($size)! Try again!"
  exit 1
fi
blocks=$(( $size / $block ))


# generate blank (zeroized) image file
img_blank="$OUT/blank.img"
if [ ! -f "$img_blank" ] ; then
  # full-zeroize: prevents loop device mount issues & allows 'dd conv=sparse' to work optimally
  dd if=/dev/zero of="$img_blank" bs="$block" count="$blocks" oflag=direct status=progress
fi


# clone empty usb img from blank
img_usb="$OUT/usb.img"
cp --sparse=always "$img_blank" "$img_usb"


# unmount any previously-mounted loop devices
part_label="zarf-boots"
mountpoint="$OUT/loop/$part_label" ; mkdir --parents "$mountpoint"
needle=$( basename "$img_usb" )
if $( losetup --list | grep --silent "$needle" ) ; then
  if [ -n "$( mount | grep "$mountpoint" )" ] ; then su -c "umount '$mountpoint'" ; fi
  su -c "losetup --detach $( losetup | grep "$needle" | awk '{print $1}' )"
fi


# mount img file as loop device
su -c "losetup --partscan --find '$img_usb'"
loop_dev=$( losetup | grep "$img_usb" | awk '{print $1}' )


# write iso to img file
su -c "dd if='$ZARF_BOOTS_ISO' of='$loop_dev' bs='$block' oflag=direct status=progress"


# expand GPT to fill entire USB
# https://community.tenable.com/s/article/Unable-to-satisfy-all-constraints-on-the-partition-when-expanding-Tenable-Core-disk
# https://unix.stackexchange.com/questions/317564/expanding-a-disk-with-a-gpt-table
su -c "sgdisk --move-second-header '$loop_dev'"


# add data partition (filling remaining space)
last_sector=$(
  su -c "parted '$loop_dev' --script 'unit s print' |
    grep '^ 3' |
    awk '{print \$3}' |
    sed 's/s//'"
)

# Warning: The resulting partition is not properly aligned for best performance:
# 3858211s % 2048s != 0s
sector_bound=$(( "$last_sector" - ( "$last_sector" % 2048 ) ))
next_sector=$(( "$sector_bound" + 2048 ))
su -c "parted --align optimal '$loop_dev' mkpart '$part_label' ext4 '$next_sector's 100%"

data_part="/dev/$( lsblk "$loop_dev" --raw | sort | tail -n 1 | awk '{print $1}' )"
su -c "mkfs -t ext4 '$data_part'"
su -c "e2label '$data_part' '$part_label'"


# mount new data partition
su -c "mount '$data_part' '$mountpoint'"


# delete unnecessary recovery dir
# https://www.baeldung.com/linux/lost-found-directory
su -c "rm --recursive --force '$mountpoint/lost+found'"


# copy deps to mountpoint
su -c "cp \
  '$ZARF_BIN' \
  '$ZARF_INIT' \
  '$ZARF_PXE_PKG' \
  './firstboot.sh' \
  './runonce.service' \
  '$mountpoint'"


# unmount / remove img file from loop device
if [ -n "$( mount | grep "$mountpoint" )" ] ; then su -c "umount '$mountpoint'" ; fi
rm --recursive --force "$mountpoint"
su -c "losetup --detach '$loop_dev'"
