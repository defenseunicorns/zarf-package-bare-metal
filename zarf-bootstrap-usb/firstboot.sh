#!/bin/bash

# Safer bash script
set -euo pipefail

cd /zarf-boots

ZARF=$( basename $( ls zarf_* ))
chmod +x "$ZARF"

PXE_PKG=$( basename $( ls zarf-package-zarf-pxe* ))

./$ZARF init --confirm --components k3s --no-progress

./$ZARF package deploy "$PXE_PKG" --confirm --no-progress

systemctl disable runonce.service

rm -f /etc/systemd/runonce.service