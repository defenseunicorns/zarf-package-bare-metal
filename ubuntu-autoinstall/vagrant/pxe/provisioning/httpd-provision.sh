#!/bin/bash

# Safer bash script
set -euo pipefail

# Download and install script dependencies
apt install apt-rdepends -y

# Create httpd directory structure
mkdir -p /var/www/html/isos
mkdir -p /var/www/html/roles/zarf-games
mkdir -p /var/www/html/packages

# Download Ubuntu 20 iso if it doesn't exist
if [ ! -f "ubuntu.iso" ]; then
  wget https://releases.ubuntu.com/20.04/ubuntu-20.04.2-live-server-amd64.iso -q -O ubuntu.iso
fi

# Copy Ubuntu iso to apache content directory
cp -p ./ubuntu.iso /var/www/html/isos/ubuntu22.iso

# Copy roles and scripts to apache directory
cp -p /vagrant/apache/role-zarf-games.yml   /var/www/html/roles/zarf-games/user-data
cp -p /vagrant/apache/job-zarf-games.sh  /var/www/html/roles/zarf-games/job-zarf-games.sh

cp -p /vagrant/apache/runonce.service  /var/www/html/roles/zarf-games/
cp -p /vagrant/zarf/zarf*  /var/www/html/roles/zarf-games/

# Create meta-data files for ubuntu autoinstall
touch /var/www/html/roles/zarf-games/meta-data