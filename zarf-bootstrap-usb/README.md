### TODOs
? USB build workstation
  - dd : to erase any data on USB key
  - parted : to lay down new partitions 
  - syslinux-utils : for isohybrid tool (to update bootable ISO)

? USB stick (wants)
  - partition 1-3: bootable Ubuntu server installer
  - partition 4: files / add'l deps
  
x tried custom USB key (using isohybrid to modify ISO)
  - https://askubuntu.com/a/971205
  - No good -- unusable ISO

o tried to dd distro ISO to disk & then add a new partition to fill remaining spce
  - worked great!
  - was able to install from in AND mount usb to access files

- update make_usb.sh script to allow dd & then add partition

- figure out how to run bootable USB install inside Vagrant..?

- figure out how to do an unattended install?  Where does the cloud-init.yaml live?
    - create a simple one & prove that unattended installer can use files from data partition.
    - i.e. https://pastebin.com/THdw6nnP