#!/bin/bash
# Reqs:
# - run as root (i.e. sudo)
# 
# Refs:
# - https://askubuntu.com/questions/423300/live-usb-on-a-2-partition-usb-drive

here=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# download zarf bin
DL=".downloads"

ZARF_RELS="https://github.com/defenseunicorns/zarf/releases/download"
ZARF_INIT="${ZARF_RELS}/v0.24.2/zarf-init-amd64-v0.24.2.tar.zst"
ZARF_BIN="${ZARF_RELS}/v0.24.2/zarf_v0.24.2_Linux_amd64"
ZARF_SUMS="${ZARF_RELS}/v0.24.2/checksums.txt"

SUMS=$( basename "$ZARF_SUMS" )
if [ ! -f "$DL/$SUMS" ] ; then
  curl --location --output "$DL/$SUMS" "$ZARF_SUMS"
fi

BIN=$( basename "$ZARF_BIN" )
if [ ! -f "$DL/$BIN" ] ; then
  curl --location --output "$DL/$BIN" "$ZARF_BIN"
fi

sumcheck=$( cd "$DL" ; cat "$SUMS" | grep "$BIN" | sha256sum --check )
if [ $? -ne 0 ] ; then
  echo ""
  echo "$BIN checksum did not match!  Delete & retry!"
  echo ""
  exit 1
fi
echo "sha256sum: $sumcheck"

INIT=$( basename "$ZARF_INIT" )
if [ ! -f "$DL/$INIT" ] ; then
  curl --location --output "$DL/$INIT" "$ZARF_INIT"
fi

sumcheck=$( cd "$DL" ; cat "$SUMS" | grep "$INIT" | sha256sum --check )
if [ $? -ne 0 ] ; then
  echo ""
  echo "$INIT checksum did not match!  Delete & retry!"
  echo ""
  exit 1
fi
echo "sha256sum: $sumcheck"

chmod +x "$DL/$BIN"

# build Zarf PXE package
(
  cd ../zarf-package-pxe-server

  PXE_PKG="zarf-package-zarf-pxe-amd64.tar.zst"
  if [ ! -f "$here/$DL/$PXE_PKG" ] ; then
    "$here/$DL/$BIN" package create --confirm
    mv "$PXE_PKG" "$here/$DL"
  fi
)