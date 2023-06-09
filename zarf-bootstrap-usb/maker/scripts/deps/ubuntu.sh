#!/bin/bash
OUT="$1"

VERSION="22.04.2"
RELEASE="https://releases.ubuntu.com/${VERSION}"
REMOTE_ISO="$RELEASE/ubuntu-${VERSION}-live-server-amd64.iso"
REMOTE_SUMS="$RELEASE/SHA256SUMS"

ISO=$( basename "$REMOTE_ISO" )
LOCAL_ISO="$OUT/$ISO"
if [ ! -f "$LOCAL_ISO" ] ; then
  curl --location --output "$LOCAL_ISO" "$REMOTE_ISO"
fi

SUMS=$( basename "$REMOTE_SUMS" )
LOCAL_SUMS="$OUT/$SUMS"
if [ ! -f "$LOCAL_SUMS" ] ; then
  curl --location --output "$LOCAL_SUMS" "$REMOTE_SUMS"
fi

sumcheck=$( cd "$OUT" ; cat "$SUMS" | grep "$ISO" | sha256sum --check )
if [ $? -ne 0 ] ; then
  echo ""
  echo "$LOCAL_ISO checksum did not match!  Delete & retry!"
  echo ""
  exit 1
fi
echo "sha256sum: $sumcheck"