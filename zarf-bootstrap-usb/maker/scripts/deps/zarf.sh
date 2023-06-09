#!/bin/bash
OUT="$1"

VERSION="v0.27.1"
RELEASES="https://github.com/defenseunicorns/zarf/releases/download"
REMOTE_INIT="${RELEASES}/${VERSION}/zarf-init-amd64-${VERSION}.tar.zst"
REMOTE_BIN="${RELEASES}/${VERSION}/zarf_${VERSION}_Linux_amd64"
REMOTE_SUMS="${RELEASES}/${VERSION}/checksums.txt"

SUMS=$( basename "$REMOTE_SUMS" )
LOCAL_SUMS="$OUT/$SUMS"
if [ ! -f "$LOCAL_SUMS" ] ; then
  curl --location --output "$LOCAL_SUMS" "$REMOTE_SUMS"
fi

BIN=$( basename "$REMOTE_BIN" )
LOCAL_BIN="$OUT/$BIN"
if [ ! -f "$LOCAL_BIN" ] ; then
  curl --location --output "$LOCAL_BIN" "$REMOTE_BIN"
fi

sumcheck=$( cd "$OUT" ; cat "$SUMS" | grep "$BIN" | sha256sum --check )
if [ $? -ne 0 ] ; then
  echo ""
  echo "$LOCAL_BIN checksum did not match!  Delete & retry!"
  echo ""
  exit 1
fi
echo "sha256sum: $sumcheck"

INIT=$( basename "$REMOTE_INIT" )
LOCAL_INIT="$OUT/$INIT"
if [ ! -f "$LOCAL_INIT" ] ; then
  curl --location --output "$LOCAL_INIT" "$REMOTE_INIT"
fi

sumcheck=$( cd "$OUT" ; cat "$SUMS" | grep "$INIT" | sha256sum --check )
if [ $? -ne 0 ] ; then
  echo ""
  echo "$LOCAL_INIT checksum did not match!  Delete & retry!"
  echo ""
  exit 1
fi
echo "sha256sum: $sumcheck"

chmod +x "$LOCAL_BIN"