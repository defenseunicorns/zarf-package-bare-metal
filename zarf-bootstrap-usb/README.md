### TODOs
? USB build workstation (Ubuntu 20.04)
  - fdisk, udevadm : to discover / display USB drive
  - dd, blockdev, sgdisk : to erase / write data on USB drive
  - mount, unmount : to allow access to USB drive
  - curl, sha256sum : to download installer ISO
  - parted, e2label : to lay down new partitions
  - p7zip : to unpack vanilla ISO
  - xorriso : to repack autoinstall-enabled ISO
  - zarf : to build PXE package

? USB stick (wants)
  - partition 1-3: bootable Ubuntu server installer
  - partition 4: data files / add'l deps
  
x tried custom USB key (using isohybrid to modify ISO)
  - https://askubuntu.com/a/971205
  - No good -- unusable ISO

o tried to dd distro ISO to disk & then add a new partition to fill remaining spce
  - worked great!
  - was able to install from in AND mount usb to access files

o update make_usb.sh script to allow dd & then add partition

o figure out how to run bootable USB install inside Vagrant..?

o figure out how to do an unattended install?  Where does the cloud-init.yaml live?

- figure out how to build Zarf PXE package
  - zarf package create

- download deps & add to USB

- add firstboot script & runonce service
  - zarf-package-bare-metal/zarf-package-pxe-server/manifests/games-role.cm.yaml

- make sure it works without internet connection on the VM!