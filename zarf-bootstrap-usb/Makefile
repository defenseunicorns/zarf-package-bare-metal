HERE := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

build: ## produces ready-to-burn bootable USB img
	@$(HERE)10_loop_usb.sh

rebuild: clean-mnt clean-mod clean-loop build ## cleans all-but-download-cache & builds usb.img

clean-downloads: ##
	rm -rf $(HERE).downloads

clean-loop: ##
	rm -rf $(HERE).loop_usb

clean-mnt: ##
	rm -rf $(HERE).mnt

clean-mod: ##
	rm -rf $(HERE).mod_iso

clean: clean-downloads clean-mnt clean-loop clean-mod ## delete all working dirs

# write-usb: ## usb.img --> /dev/usb-blah-blah
# 	# https://stackoverflow.com/questions/714100/os-detecting-makefile

vagrant-up-img: ## bring up usb.img-based vagrant-libvirt VM
	VAGRANT_VAGRANTFILE=Vagrantfile_img vagrant up

vagrant-destroy-img: ## destroy usb.img-based vagrant-libvirt VM
	VAGRANT_VAGRANTFILE=Vagrantfile_img vagrant destroy -f

# vagrant-up-usb: ## bring up usb device-based vagrant-libvirt VM
# 	VAGRANT_VAGRANTFILE=Vagrantfile_usb vagrant up

# vagrant-destroy-img: ## destroy usb device-based vagrant-libvirt VM
# 	VAGRANT_VAGRANTFILE=Vagrantfile_usb vagrant destroy -f

help: ## display this help information
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'