#!/bin/bash
OUT="$1"
DEPS="$2"

here=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
iso_original="$( compgen -G "$DEPS/ubuntu/ubuntu-*-amd64.iso" )"
iso_unpacked="$OUT/zarf-boots.fs"
iso_zarfboot="$OUT/zarf-boots.iso"


# unpack original iso
boot="[BOOT]"
boot_imgs="$OUT/$boot"
if [ ! -d "$iso_unpacked" ] ; then
  7z -y x -o"$iso_unpacked" "$iso_original"
  mv "$iso_unpacked/$boot" "$OUT"
fi


# inject autoinstall boot option
grubcfg="$iso_unpacked/boot/grub/grub.cfg"

read -r -d '' boot_option <<'EOF'
menuentry "Install Zarf Boots!" {
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


# disable autoselection of destructive Zarf-paving menuentry
sed -i 's/set timeout=30/set timeout=-1/' "$grubcfg"


# add autoinstall config directory
AI="$iso_unpacked/zarf" ; mkdir -p "$AI"
touch "$AI/meta-data"
cp "./autoinstall.yaml" "$AI/user-data"


# pack modified iso
if [ ! -f "$iso_zarfboot" ] ; then
  xorriso -as mkisofs -r \
    -V 'Zarf Boots' \
    -o "$iso_zarfboot" \
    --grub2-mbr "$boot_imgs/1-Boot-NoEmul.img" \
    -partition_offset 16 \
    --mbr-force-bootable \
    -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b "$boot_imgs/2-Boot-NoEmul.img" \
    -appended_part_as_gpt \
    -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
    -c '/boot.catalog' \
    -b '/boot/grub/i386-pc/eltorito.img' \
      -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
    -eltorito-alt-boot \
    -e '--interval:appended_partition_2:::' \
    -no-emul-boot \
    "$iso_unpacked"
fi
