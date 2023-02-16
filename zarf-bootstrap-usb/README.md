### TODOs
? USB build workstation (Ubuntu 20.04)
  - fdisk, udevadm : to discover / display USB drive
  - dd, blockdev, sgdisk : to erase / write data on USB drive
  - mount, unmount : to allow access to USB drive
  - curl, sha256sum : to download installer ISO
  - parted : to lay down new partitions

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

- figure out how to run bootable USB install inside Vagrant..?

- figure out how to do an unattended install?  Where does the cloud-init.yaml live?
    - create a simple one & prove that unattended installer can use files from data partition.
    - i.e. https://pastebin.com/THdw6nnP