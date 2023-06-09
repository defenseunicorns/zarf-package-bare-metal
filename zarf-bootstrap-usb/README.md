### Usage

Build Ubuntu-based, bootable, "Zarf Boots" image file with:

```
make create
```
&nbsp;


Boot a (libvirt-based) VM from image file with:

```
make vagrant-img-up
make vagrant-img-destroy
```
Watch the VM work:

  1. Open the VM console (use `virt-viewer`)

  1. Select the "Zarf Boots" GRUB option & wait for autoinstaller to run & VM to reboot.

  1. Login as user: "admin" with password "admin" and Zarf some things!

&nbsp;


Burn it to a bootable USB device with:

```
make write
```
&nbsp;


Boot a (libvirt-based) VM from usb device with:

```
make vagrant-usb-up
make vagrant-usb-destroy
```
> Be sure to update the `Vagrant_usb` file! Libvirt requires a h/w-based device identifier to know which USB key to use.

Watch the VM work:

  1. Open the VM console (use `virt-viewer`)

  1. Type "exit" at the UEFI boot screen (if it hangs there)
  
  1. Select your USB device from the UEFI boot options

  1. Select the "Zarf Boots" GRUB option & wait for autoinstaller to run & VM to reboot.

  1. Login as user: "admin" with password "admin" and Zarf some things!

&nbsp;


### Activity Log
- ✓ -- USB build workstation (Ubuntu 20.04)
  - fdisk, lsblk, udevadm : to discover / display drive information
  - dd, blockdev, sgdisk, mkfs : to erase / write data to drive
  - mount, unmount : to allow access to drive
  - curl, sha256sum : to download installer ISO
  - parted, e2label : to lay down new partitions
  - p7zip : to unpack vanilla ISO
  - xorriso : to repack autoinstall-enabled ISO
  - losetup : for working with loop devices
  - zarf : to build PXE package

- ✓ -- USB stick (wants)
  - partition 1-3: bootable Ubuntu server installer
  - partition 4: data files / add'l deps
  
- ✕ -- tried custom USB key (using isohybrid to modify ISO)
  - https://askubuntu.com/a/971205
  - No good -- unusable ISO

- ✓ -- tried to dd distro ISO to disk & then add a new partition to fill remaining spce
  - worked great!
  - was able to install from in AND mount usb to access files

- ✓ -- update make_usb.sh script to allow dd & then add partition

- ✓ -- figure out how to run bootable USB install inside Vagrant..?

- ✓ -- figure out how to do an unattended install?  Where does the cloud-init.yaml live?

- ✓ -- figure out how to build Zarf PXE package
  - zarf package create

- ✓ -- download deps & add to USB

- ✓ -- add firstboot script & runonce service
  - zarf-package-bare-metal/zarf-package-pxe-server/manifests/games-role.cm.yaml

- ✓ -- get the flippin' USB sync to work!
  - so slow! (30 min to write 2GB?!)

- ✓ build the USB stick image against a loop-mounted .img on disk
    - get to boot in Vagrantfile via file mount!

- ✓ write USB stick image to USB
  - get to boot in Vagrantfile via USB!

- ✓ -- Figure out why Zarf PXE package pods won't start
  - some kind of port conflict..?
  - "Warning --> FailedScheduling --> 5m30s --> default-scheduler --> 0/1 nodes are available: 1 node(s) didn't have free ports for the requested pod ports."
  - as passing args to K3S that caused Traefik to start which cause conflict
    - rm'd the K3S flags and everything went well

- ✓ -- get usb.img build into one-or-more containers.
  - much less likely to "works on my machine" across the team!

- ? -- would like to move write_usb.sh into a container too (if possible..?)
  - would avoid having to install expected utils (parted, etc.) on host
  - not sure of the feasibility cross-platform though.

- ? -- make sure it works without internet connection on the VM!
  - test on airgapped hardware!

- ? -- find a way to notify user that runonce.service has completed successfully... or not?  MotD?  Something else?

- ? -- add folder-based placeholder for containing files we want burned and them add them to the usb.img during creation

- ? -- currently using hard-coded 16GB(-ish) blank.img / usb.img, which could be:
  - too small to fit all the files needed (i.e. if a USB HD is used), or
  - much larger than the content needed and so will waste time on blank.img gen.
  - to solve that, would like to move to smarter USB creation strat that:
    - can know all of what is needed _first_, and then gen an right-sized blank from that.
    
