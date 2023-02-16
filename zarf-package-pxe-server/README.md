## zarf-package-pxe-server

>⚠️ **This is a work in progress and still under active development.**

This defines a Zarf package for a PXE server to provision k8s clusters from bare metal

#### **Building**

Clone the repo:

```bash
git clone https://github.com/defenseunicorns/zarf-package-bare-metal.git
cd zarf-package-bare-metal
```

To build the Zarf package:

```bash
cd zarf-package-pxe-server
zarf package create
```

#### **Testing**

For testing `zarf-package-pxe-server`, two `Vagrantfile`s are provided, in the `test/` folder. You'll need Vagrant installed along with the libvirt Vagrant provider. [Instructions here](https://vagrant-libvirt.github.io/vagrant-libvirt/)

To run the server:


```bash
cp zarf-package-pxe-server.tar.zst test/pxe
cd test/pxe
vagrant up
```

Then run the client:


```bash
cd test/client
vagrant up
```

You should see the client grab an IP from the PXE server, and then a GRUB boot screen with a couple of client personas to choose from.
