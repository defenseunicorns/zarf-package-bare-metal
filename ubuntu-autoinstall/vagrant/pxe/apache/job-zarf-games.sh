#!/bin/bash

# Safer bash script
set -euo pipefail

cd /root

wget http://192.168.0.254/roles/zarf-games/zarf -q
wget http://192.168.0.254/roles/zarf-games/zarf-init-amd64-v0.27.1.tar.zst -q
wget http://192.168.0.254/roles/zarf-games/zarf-package-dos-games-amd64.tar.zst -q

chmod +x ./zarf

./zarf init --confirm --components k3s --set K3S_ARGS=""

./zarf package deploy zarf-package-dos-games-amd64.tar.zst --confirm

systemctl disable runonce.service

rm -f /etc/systemd/runonce.service