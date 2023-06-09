#!/bin/bash

OUT="$1"

# # build Zarf PXE package
# ZARF_PXE_PKG="zarf-package-zarf-pxe-amd64.tar.zst"
# (
#   cd "$here/../zarf-package-pxe-server"

#   if [ ! -f "$DL/$ZARF_PXE_PKG" ] ; then
#     "$DL/$ZARF_BIN" package create --confirm
#     mv "$ZARF_PXE_PKG" "$DL"
#   fi
# )