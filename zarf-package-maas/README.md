## MAAS Server Zarf Package

>⚠️ **This is a work in progress and still under active development.**

This defines a Zarf package for a MaaS server to provision k8s clusters from bare metal

#### **Building**

Clone the repo:

```bash
git clone https://github.com/defenseunicorns/zarf-package-bare-metal.git
cd zarf-package-bare-metal
```

To build the Zarf package:

```bash
cd zarf-package-maas
zarf package create
```

#### **Testing**

For testing `zarf-package-maas`, two `Vagrantfile`s are provided, in the `test/` folder. You'll need Vagrant installed along with the libvirt Vagrant provider. [Instructions here](https://vagrant-libvirt.github.io/vagrant-libvirt/)

To run the server:


```bash
cp zarf-package-maas-amd64-0.0.x.tar.zst test/maas
cd test/maas
vagrant up
```

Then run the client:


```bash
cd test/client
vagrant up
```

You should see the client grab an IP from the MaaS server, and then a boot screen with a couple of client personas to choose from.
