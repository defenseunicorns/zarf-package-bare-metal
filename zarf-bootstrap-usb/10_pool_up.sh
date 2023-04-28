#!/bin/bash

here=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

POOL_DIR="$here/.loop_usb"
POOL_NAME=$( basename "$POOL_DIR" )

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