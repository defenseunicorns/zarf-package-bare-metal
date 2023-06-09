#!/bin/bash
OUT="$1"
DEPS="$2"

here=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
root=$( realpath "$(pwd)/.." )

zarf=$( find "$DEPS/zarf" -path "*/zarf_*_amd64" -type f )
source="$root/zarf-package-pxe-server"
package="$OUT/zarf-package-*-amd64.tar.zst"

if ! compgen -G "$package" > /dev/null ; then
  su -c "'$zarf' package create '$source' --output-directory '$OUT' --confirm"
  su -c "chown $(id -u):$(id -g) $package"
fi
