#!/bin/bash

OUT="$1"

RELEASES="https://github.com/defenseunicorns/zarf/releases/download"
VERSION="v0.27.1"
REMOTE_INIT="${RELEASES}/${VERSION}/zarf-init-amd64-${VERSION}.tar.zst"
REMOTE_BIN="${RELEASES}/${VERSION}/zarf_${VERSION}_linux_amd64"
REMOTE_SUMS="${RELEASES}/${VERSION}/checksums.txt"

LOCAL_SUMS="$OUT/$( basename "$REMOTE_SUMS" )"
if [ ! -f "$LOCAL_SUMS" ] ; then
  curl --location --output "$LOCAL_SUMS" "$REMOTE_SUMS"
fi

# ZARF_BIN=$( basename "$REMOTE_ZARF_BIN" )
# if [ ! -f "$DL/$ZARF_BIN" ] ; then
#   curl --location --output "$DL/$ZARF_BIN" "$REMOTE_ZARF_BIN"
# fi

# sumcheck=$( cd "$DL" ; cat "$ZARF_SUMS" | grep "$ZARF_BIN" | sha256sum --check )
# if [ $? -ne 0 ] ; then
#   echo ""
#   echo "$ZARF_BIN checksum did not match!  Delete & retry!"
#   echo ""
#   exit 1
# fi
# echo "sha256sum: $sumcheck"

# ZARF_INIT=$( basename "$REMOTE_ZARF_INIT" )
# if [ ! -f "$DL/$ZARF_INIT" ] ; then
#   curl --location --output "$DL/$ZARF_INIT" "$REMOTE_ZARF_INIT"
# fi

# sumcheck=$( cd "$DL" ; cat "$ZARF_SUMS" | grep "$ZARF_INIT" | sha256sum --check )
# if [ $? -ne 0 ] ; then
#   echo ""
#   echo "$ZARF_INIT checksum did not match!  Delete & retry!"
#   echo ""
#   exit 1
# fi
# echo "sha256sum: $sumcheck"

# chmod +x "$DL/$ZARF_BIN"