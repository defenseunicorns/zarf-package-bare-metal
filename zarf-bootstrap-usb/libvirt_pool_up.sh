#!/bin/bash

here=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

POOL_DIR="$here/.build/03_zarf-boots-img"
POOL_NAME=$( basename "$POOL_DIR" )
USB_IMG="$POOL_DIR/usb.img"

# create directory-based storage pool (if not exist)
if ! $( virsh pool-list --name --all | grep --silent "$POOL_NAME" ) ; then
  virsh pool-define-as \
    --name "$POOL_NAME" \
    --type dir \
    --target "$POOL_DIR"
fi
if $( virsh pool-list --name --inactive | grep --silent "$POOL_NAME" ) ; then
  virsh pool-start "$POOL_NAME"
fi

# make it accessible for booting by libvirt!
chmod 777 "$USB_IMG"
