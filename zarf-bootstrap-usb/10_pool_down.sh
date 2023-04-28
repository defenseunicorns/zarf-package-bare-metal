#!/bin/bash

here=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

POOL_DIR="$here/.loop_usb"
POOL_NAME=$( basename "$POOL_DIR" )

# remove directory-based storage pool
if $( virsh pool-list --name | grep --silent "$POOL_NAME" ) ; then
  virsh pool-destroy "$POOL_NAME"
fi
if $( virsh pool-list --name --all | grep --silent "$POOL_NAME" ) ; then
  virsh pool-undefine "$POOL_NAME"
fi