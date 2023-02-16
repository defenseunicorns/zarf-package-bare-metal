#!/bin/bash
# Reqs:
# - run as root (i.e. sudo)
#
# Refs:
# - https://www.pugetsystems.com/labs/hpc/ubuntu-22-04-server-autoinstall-iso/

# download installable iso
# Ubuntu 22.04 Server ISO
DL="./.downloads" ; mkdir -p "$DL"

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

# unpack vanilla iso
WD="./.mod_iso" ; mkdir -p "$WD"
unpack="$WD/${iso%.iso}" ; mkdir -p "$unpack"

7z -y x "$DL/$iso" -o"$unpack"

# mv old partition images out of the way
mv "$unpack/[BOOT]" "$WD/BOOT"

# inject new autoinstall boot option
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

# repack modified iso
xorriso -as mkisofs -r \
  -V 'Zarf Boots' \
  -o "$WD/zarf-boots.iso" \
  --grub2-mbr "$WD/BOOT/1-Boot-NoEmul.img" \
  -partition_offset 16 \
  --mbr-force-bootable \
  -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b "$WD/BOOT/2-Boot-NoEmul.img" \
  -appended_part_as_gpt \
  -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
  -c '/boot.catalog' \
  -b '/boot/grub/i386-pc/eltorito.img' \
    -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
  -eltorito-alt-boot \
  -e '--interval:appended_partition_2:::' \
  -no-emul-boot \
  "$unpack"
