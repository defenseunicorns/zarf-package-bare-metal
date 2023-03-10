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
