# zarf-package-bare-metal
![Dash Days](https://img.shields.io/badge/Dash%20Days-best--project-blueviolet)
![Apache License](https://img.shields.io/github/license/defenseunicorns/zarf-package-bare-metal)
![Issues](https://img.shields.io/github/issues/defenseunicorns/zarf-package-bare-metal)
<img align="right" alt="Stars" src="https://img.shields.io/github/stars/defenseunicorns/zarf-package-bare-metal?style=social">

>⚠️ **This is a work in progress and still under active development.**

This is an experimental package to deploy Zarf packages on bare metal machines.  The concept is to take a USB drive and use it to bootstrap a utility node that can be used to bootstrap other nodes over a local network.  See the below diagram for a layout of how this works:

![Zarf Bare Metal Diagram](.images/zarf-bare-metal.drawio.svg)


## How this Works

### zarf-bootstrap-usb

The `zarf-bootstrap-usb` subproject creates an Ubuntu bootable drive along with an additional partition with files
necessary to run the PXE server described below.

[[More Info](zarf-bootstrap-usb)]

### zarf-package-pxe-server

The `zarf-package-pxe-server` subproject defines a Zarf package `zarf-pxe`. This package runs a PXE and nginx server
to handle DHCP/PXE booting along with Ubuntu unattended installation files. This project, when built using
`zarf package create` will download the Ubuntu ISO, extract the necessary GRUB EFI files for PXE booting, and then
put the package together with all necessary files. When deployed, this package will start listening for DHCP requests
on its subnet and reply with appropriate TFTP details.

The `zarf-pxe` server will instruct clients to install Ubuntu (unattended). This sets up Zarf on the client along with 
some classic games that run in k3s on the client.

[[More Info](zarf-package-pxe-server)]

### zarf-package-maas

The `zarf-package-maas` subproject defines a Zarf package `zarf-maas`. This will be an alternative to using the dnsmasq Zarf package in `zarf-pxe`. This package has three parts:

1. Container build definition in `region-rack-image`. This Dockerfile will build a container containing
   Canonical's MAAS. MAAS needs systemd to run, so `systemd` is the entrypoint for the container. Additional
   init scripts for MAAS are provided in the form of a systemd unit file `runonce.service` and shell script
   `addmaasuser.sh`

   To run the docker image by itself, for testing, run:

```shell
docker build . -t maas
docker run -it --cgroupns=host --tmpfs /tmp --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup -p 5240:5240 maas
```

  You can access the MAAS web interface at `http://yourmachineIP:5240` and login with default `admin:admin` credentials.

  The build for this container is also available as a GitHub Action, defined in `.github/workflows/build_container.yaml`

2. Zarf package and associated manifests in `zarf.yaml` and folder `manifests`. 

  The build for this Zarf package is also available as a GitHub Action, defined in `.github/workflows/build_maas_package.yaml`

  When running this, you'll need to bump the version number in the workflow as well as the `zarf.yaml` file.

3. Test Vagrantfiles. These are a work in progress. At current the `maas/Vagrantfile` will successfully set up Zarf
   and deploy the MAAS Zarf package. It runs, though we're still figuring out how to access it via Vagrant's network
   interface.
