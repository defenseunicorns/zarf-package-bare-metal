### Usage

Download Ubuntu 22.04 distro & inject custom autoinstall scripts:

```
# ./01_mod_iso.sh
```

Write custom ISO to USB drive & create data partition in remaining free space:

```
# ./02_make_usb.sh
```

Download Zarf distro & build Zarf PXE package:

```
# ./03_build_zarf.sh
```

Write Zarf / PXE package / firstboot scripts (and any other deps) to USB data partition:

```
# ./04_load_usb.sh
```

Watch it work:

- Modify the Vagrant file so it uses your specific USB device (by matching vendor / product IDs), like so:

    ```
    # lsusb: Bus 001 Device 007: ID 0781:55a5 SanDisk Corp. Cruzer U

    lv.usb :vendor => '0x0781', :product => '0x55a5'
    ```

- Start the VM:

    ```
    $ vagrant up
    ```
- Boot to USB:
  1.  Open the VM console (via virt-viewer!)

  1. type "exit" at the UEFI boot screen
  
  1. Select your USB device from the UEFI boot options

- Wait for autoinstaller to run & VM to reboot.

- Login as user: "admin" with password "admin" and Zarf some things!

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

- ? write USB stick image to USB
  - get to boot in Vagrantfile via USB!

- ✓ -- Figure out why Zarf PXE package pods won't start
  - some kind of port conflict..?
  - "Warning --> FailedScheduling --> 5m30s --> default-scheduler --> 0/1 nodes are available: 1 node(s) didn't have free ports for the requested pod ports."
  - as passing args to K3S that caused Traefik to start which cause conflict
    - rm'd the K3S flags and everything went well

- ? -- make sure it works without internet connection on the VM!
  - test on airgapped hardware!

- ? -- find a way to notify user that runonce.service has completed successfully... or not?  MotD?  Something else?

- ? -- find a way to build sparse modified iso / usb.img file (currently hard-coded to 16GB)
  - https://www.libguestfs.org/virt-sparsify.1.html ..?

- ? -- get usb.img build into one-or-more containers.

- ? -- add folder-based placeholder for containing files we want burned and them add them to the usb.img during creation

- ? -- currently using hard-coded 16GB blank.img / usb.img, which... takes too long to dd to disk
  - move to multi-stage USB creation where:
    - download zarf deps & size them
    - inspect "me too" deps directory & size it
    - create a zeroized base.img that can just-barely hold all that
    - dd ubuntu iso onto base.img
    - add data partition to base.img
    - loopback mount data partition & copy over deps
    - umount loopback
    - write base.img to usb device (so dd'ing 5GB instead of 16GB)
    - post-write, expand data partition to fill remaining space on disk
