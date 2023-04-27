HERE := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))


build: ## produces ready-to-burn bootable USB img
	@$(HERE)10_loop_usb.sh

rebuild: clean-mnt clean-mod clean-loop build ## cleans everything & builds USB

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

# vagrant:
	

# vagrant-img:
# 	VAGRANT_VAGRANTFILE=Vagrantfile_img $(MAKE) vagrant

# vagrant-usb:
# 	VAGRANT_VAGRANTFILE=Vagrantfile_usb $(MAKE) vagrant

help: ## Display this help information
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'