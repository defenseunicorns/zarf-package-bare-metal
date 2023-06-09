#!/bin/bash
OUT="$1"
DEPS="$2"

here=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
iso_original="$( compgen -G "$DEPS/ubuntu/ubuntu-*-amd64.iso" )"
iso_unpacked="$OUT/zarf-boots.fs"
iso_zarfboot="$OUT/zarf-boots.iso"

# TODO: delete!
echo "$iso_original"
echo "$iso_unpacked"
echo "$iso_zarfboot"

# unpack original iso
7z -y x -o"$iso_unpacked" "$iso_original"


# # mv boot partition images up to working directory
# mv "$unpack/[BOOT]" "$WD_ISO/BOOT"


# # inject autoinstall boot option
# grubcfg="$unpack/boot/grub/grub.cfg"

# read -r -d '' boot_option <<'EOF'
# menuentry "Autoinstall Zarf Bootstrapper" {
#   set gfxpayload=keep
#   linux   /casper/vmlinuz quiet autoinstall ds=nocloud\;s=/cdrom/zarf/  ---
#   initrd  /casper/initrd
# }
# EOF
# needle=$( cat "$grubcfg" | awk '/Try or Install/{ print NR; exit }' )
# count=$( wc --lines "$grubcfg" | awk '{print $1}' )

# head=$( cat "$grubcfg" | head -n $(($needle - 1)) )
# tail=$( cat "$grubcfg" | tail -n $(($count - $needle + 1 )) )

# echo "$head" > "$grubcfg"
# echo "" >> "$grubcfg"
# echo "$boot_option" >> "$grubcfg"
# echo "" >> "$grubcfg"
# echo "$tail" >> "$grubcfg"


# # disable autoselection of destructive Zarf-paving menuentry
# sed -i 's/set timeout=30/set timeout=-1/' "$grubcfg"


# # add autoinstall config directory
# AI="$unpack/zarf" ; mkdir -p "$AI"
# touch "$AI/meta-data"
# cp "./autoinstall.yaml" "$AI/user-data"


# # pack modified iso
# ZARF_ISO="$WD/zarf-boots.iso"
# xorriso -as mkisofs -r \
#   -V 'Zarf Boots' \
#   -o "$ZARF_ISO" \
#   --grub2-mbr "$WD_ISO/BOOT/1-Boot-NoEmul.img" \
#   -partition_offset 16 \
#   --mbr-force-bootable \
#   -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b "$WD_ISO/BOOT/2-Boot-NoEmul.img" \
#   -appended_part_as_gpt \
#   -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
#   -c '/boot.catalog' \
#   -b '/boot/grub/i386-pc/eltorito.img' \
#     -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
#   -eltorito-alt-boot \
#   -e '--interval:appended_partition_2:::' \
#   -no-emul-boot \
#   "$unpack"


# # set img / & write block size (in bytes)
# # https://www.gnu.org/software/coreutils/manual/html_node/numfmt-invocation.html
# # https://askubuntu.com/questions/931581/flashing-ubuntu-iso-to-usb-stick-with-dd-recommended-block-size
# # SIZE=$( numfmt --from=si 15.5G )
# SIZE="15631122432" # Cruzer USB bytes
# BLOCK=$( numfmt --from=iec-i 4Ki )
# if [ $(( $SIZE % $BLOCK )) -ne 0 ] ; then
#   echo "Block ($BLOCK) doesn't divide evenly into size ($SIZE)! Try again!"
#   exit 1
# fi