#!/bin/bash
# Reqs:
# - run as root (i.e. sudo)
#
# Refs:
# - https://www.pugetsystems.com/labs/hpc/ubuntu-22-04-server-autoinstall-iso/
# - https://linuxconfig.org/how-to-create-loop-devices-on-linux
# - https://wiki.archlinux.org/title/Parted
# - https://www.thegeekdiary.com/how-to-create-sparse-files-in-linux-using-dd-command/
# - https://wiki.archlinux.org/title/sparse_file


here=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


# download & build zarf
DL="$here/.downloads" ; mkdir --parents "$DL"

ZARF_RELS="https://github.com/defenseunicorns/zarf/releases/download"
REMOTE_ZARF_INIT="${ZARF_RELS}/v0.24.2/zarf-init-amd64-v0.24.2.tar.zst"
REMOTE_ZARF_BIN="${ZARF_RELS}/v0.24.2/zarf_v0.24.2_Linux_amd64"
REMOTE_ZARF_SUMS="${ZARF_RELS}/v0.24.2/checksums.txt"

ZARF_SUMS=$( basename "$REMOTE_ZARF_SUMS" )
if [ ! -f "$DL/$ZARF_SUMS" ] ; then
  curl --location --output "$DL/$ZARF_SUMS" "$REMOTE_ZARF_SUMS"
fi

ZARF_BIN=$( basename "$REMOTE_ZARF_BIN" )
if [ ! -f "$DL/$ZARF_BIN" ] ; then
  curl --location --output "$DL/$ZARF_BIN" "$REMOTE_ZARF_BIN"
fi

sumcheck=$( cd "$DL" ; cat "$ZARF_SUMS" | grep "$ZARF_BIN" | sha256sum --check )
if [ $? -ne 0 ] ; then
  echo ""
  echo "$ZARF_BIN checksum did not match!  Delete & retry!"
  echo ""
  exit 1
fi
echo "sha256sum: $sumcheck"

ZARF_INIT=$( basename "$REMOTE_ZARF_INIT" )
if [ ! -f "$DL/$ZARF_INIT" ] ; then
  curl --location --output "$DL/$ZARF_INIT" "$REMOTE_ZARF_INIT"
fi

sumcheck=$( cd "$DL" ; cat "$ZARF_SUMS" | grep "$ZARF_INIT" | sha256sum --check )
if [ $? -ne 0 ] ; then
  echo ""
  echo "$ZARF_INIT checksum did not match!  Delete & retry!"
  echo ""
  exit 1
fi
echo "sha256sum: $sumcheck"

chmod +x "$DL/$ZARF_BIN"

# build Zarf PXE package
ZARF_PXE_PKG="zarf-package-zarf-pxe-amd64.tar.zst"
(
  cd "$here/../zarf-package-pxe-server"

  if [ ! -f "$DL/$ZARF_PXE_PKG" ] ; then
    "$DL/$ZARF_BIN" package create --confirm
    mv "$ZARF_PXE_PKG" "$DL"
  fi
)


# download installable distro iso
URL_ISO="https://releases.ubuntu.com/22.04.1/ubuntu-22.04.1-live-server-amd64.iso"
iso=$( basename "$URL_ISO" )
if [ ! -f "$DL/$iso" ] ; then
  curl --location --output "$DL/$iso" "$URL_ISO"
fi

URL_SUMS="https://releases.ubuntu.com/22.04.1/SHA256SUMS"
sums=$( basename "$URL_SUMS" )
if [ ! -f "$DL/$sums" ] ; then
  curl --location --output "$DL/$sums" "$URL_SUMS"
fi

sumcheck=$( cd "$DL" ; cat "$sums" | grep server | sha256sum --check )
if [ $? -ne 0 ] ; then
  echo ""
  echo "$DL/$iso checksum did not match!  Delete & retry!"
  echo ""
  exit 1
fi
echo "sha256sum: $sumcheck"


# clear working directory
WD="$here/.loop_usb"
rm --recursive --force "$WD"
mkdir --parents "$WD"


# unpack vanilla iso
WD_ISO="$WD/iso"
unpack="$WD_ISO/${iso%.iso}" ; mkdir -p "$unpack"
7z -y x "$DL/$iso" -o"$unpack"


# mv boot partition images up to working directory
mv "$unpack/[BOOT]" "$WD_ISO/BOOT"


# inject autoinstall boot option
grubcfg="$unpack/boot/grub/grub.cfg"

read -r -d '' boot_option <<'EOF'
menuentry "Autoinstall Zarf Bootstrapper" {
  set gfxpayload=keep
  linux   /casper/vmlinuz quiet autoinstall ds=nocloud\;s=/cdrom/zarf/  ---
  initrd  /casper/initrd
}
EOF
needle=$( cat "$grubcfg" | awk '/Try or Install/{ print NR; exit }' )
count=$( wc --lines "$grubcfg" | awk '{print $1}' )

head=$( cat "$grubcfg" | head -n $(($needle - 1)) )
tail=$( cat "$grubcfg" | tail -n $(($count - $needle + 1 )) )

echo "$head" > "$grubcfg"
echo "" >> "$grubcfg"
echo "$boot_option" >> "$grubcfg"
echo "" >> "$grubcfg"
echo "$tail" >> "$grubcfg"


# add autoinstall config directory
AI="$unpack/zarf" ; mkdir -p "$AI"
touch "$AI/meta-data"
cp "./autoinstall.yaml" "$AI/user-data"


# pack modified iso
ZARF_ISO="$WD/zarf-boots.iso"
xorriso -as mkisofs -r \
  -V 'Zarf Boots' \
  -o "$ZARF_ISO" \
  --grub2-mbr "$WD_ISO/BOOT/1-Boot-NoEmul.img" \
  -partition_offset 16 \
  --mbr-force-bootable \
  -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b "$WD_ISO/BOOT/2-Boot-NoEmul.img" \
  -appended_part_as_gpt \
  -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
  -c '/boot.catalog' \
  -b '/boot/grub/i386-pc/eltorito.img' \
    -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
  -eltorito-alt-boot \
  -e '--interval:appended_partition_2:::' \
  -no-emul-boot \
  "$unpack"


# set img / & write block size (in bytes)
# https://www.gnu.org/software/coreutils/manual/html_node/numfmt-invocation.html
# https://askubuntu.com/questions/931581/flashing-ubuntu-iso-to-usb-stick-with-dd-recommended-block-size
# SIZE=$( numfmt --from=si 15.5G )
SIZE="15631122432" # Cruzer USB bytes
BLOCK=$( numfmt --from=iec-i 4Ki )
if [ $(( $SIZE % $BLOCK )) -ne 0 ] ; then
  echo "Block ($BLOCK) doesn't divide evenly into size ($SIZE)! Try again!"
  exit 1
fi


# create blank img file
PERSISTENT="$here/.downloads"
BLANK="$PERSISTENT/blank.img"
IMG="$WD/usb.img"

blocks=$(( $SIZE / $BLOCK ))

if [ ! -f "$BLANK" ] ; then
  # full-zeroize: prevent loop device mount issues / 'dd conv=sparse' works optimally
  dd if=/dev/zero of="$BLANK" bs="$BLOCK" count="$blocks" oflag=direct status=progress
fi

echo "Copying $(basename "$BLANK") into working directory..."
time cp "$BLANK" "$IMG"


# unmount any still-mounted loop devices from previous runs
PART_LABEL="zarf-boots"
MOUNTPOINT="/mnt/$PART_LABEL" ; mkdir --parents "$MOUNTPOINT"

if $( losetup --list | grep --silent "$IMG" ) ; then
  if [ -n "$( mount | grep "$MOUNTPOINT" )" ] ; then umount "$MOUNTPOINT" ; fi
  losetup --detach $( losetup | grep "$IMG" | awk '{print $1}' )
fi


# mount img file as loop device
losetup --partscan --find "$IMG"
loop_dev=$( losetup | grep "$IMG" | awk '{print $1}' )


# write iso to USB
dd if="$ZARF_ISO" of="$loop_dev" bs="$BLOCK" oflag=direct status=progress


# expand GPT to fill entire USB
# https://community.tenable.com/s/article/Unable-to-satisfy-all-constraints-on-the-partition-when-expanding-Tenable-Core-disk
# https://unix.stackexchange.com/questions/317564/expanding-a-disk-with-a-gpt-table
sgdisk --move-second-header "$loop_dev"


# add data partition (filling remaining space)
last_sector=$(
  parted "$loop_dev" --script 'unit s print' \
    | grep '^ 3' | awk '{print $3}' \
    | sed 's/s//' )

# Warning: The resulting partition is not properly aligned for best performance:
# 2880548s % 2048s != 0s
block_boundary=$(( "$last_sector" - ( "$last_sector" % 2048 ) ))
next_sector=$(( "$block_boundary" + 2048 ))

parted --align optimal "$loop_dev" mkpart "$PART_LABEL" ext4 "$next_sector"s 100%
data_part="/dev/$( lsblk "$loop_dev" --raw | tail -n 1 | awk '{print $1}' )"
mkfs -t ext4 "$data_part"
e2label "$data_part" "$PART_LABEL"


# mount new data partition
mount "$data_part" "$MOUNTPOINT"

# delete unnecessary recovery dir
# https://www.baeldung.com/linux/lost-found-directory
rm --recursive --force "$MOUNTPOINT/lost+found"


# copy deps to mountpoint
cp \
  "$DL/$ZARF_BIN" "$DL/$ZARF_INIT" "$DL/$ZARF_PXE_PKG" \
  "$here/firstboot.sh" "$here/runonce.service" \
  "$MOUNTPOINT"


# unmount / remove img file from loop device
umount "$MOUNTPOINT" ; rm --recursive --force "$MOUNTPOINT"
losetup --detach "$loop_dev"


# # https://www.thegeekdiary.com/how-to-create-sparse-files-in-linux-using-dd-command/
# dd if="$here/16G-blank.img" of="$here/16G-sparse.img" bs="$BLOCK" conv=sparse oflag=direct status=progress
# du --apparent-size --human-readable "$here/16G-blank.img" # apparent size
# du                 --human-readable "$here/16G-blank.img" # actual size
# du --apparent-size --human-readable "$here/16G-sparse.img"
# du                 --human-readable "$here/16G-sparse.img"
#
# dd if="$here/16G-blank.img" of=/dev/sdX bs="$BLOCK" conv=sparse,fsync oflag=direct status=progress
