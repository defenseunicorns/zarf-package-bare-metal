#!/bin/bash

# Safer bash script
set -euo pipefail

cd /zarfboots

ZARF=$( basename $( ls zarf_* ))
chmod +x "$ZARF"

PXE_PKG=$( basename $( ls zarf-package-zarf-pxe* ))

./$ZARF init --confirm --components k3s --set K3S_ARGS=""

./$ZARF package deploy "$PXE_PKG" --confirm

systemctl disable runonce.service

rm -f /etc/systemd/runonce.service