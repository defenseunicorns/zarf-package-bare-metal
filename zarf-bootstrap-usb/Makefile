HERE := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
UID := $(shell id -u)
GID := $(shell id -g)
COMPOSE_RUN := docker compose run --user "$(UID):$(GID)" --rm maker

DEPS := ./.deps
BUILD := ./.build

clean: clearDebris clearDocker ## remove all evidence of ever having run

clearDocker: ## delete maker image
	@docker compose down --remove-orphans --rmi local

clearDebris: ## delete intermediate files/folders
	@$(COMPOSE_RUN) rm -rf $(DEPS) $(BUILD)

deps: ## download deps
	@$(COMPOSE_RUN) ./maker/scripts/run.sh "$(DEPS)"

build: ## build usb.img from deps
	@$(COMPOSE_RUN) ./maker/scripts/run.sh "$(BUILD)" "$(DEPS)"

create: deps build ## download and build all-the-things

write: ## writes ready-to-burn bootable USB img to user-selected USB drive
	@$(HERE)write_usb.sh

vagrant-img-up: ## bring up usb.img-based vagrant-libvirt VM
	VAGRANT_VAGRANTFILE=Vagrantfile_img vagrant up

vagrant-img-destroy: ## destroy usb.img-based vagrant-libvirt VM
	VAGRANT_VAGRANTFILE=Vagrantfile_img vagrant destroy -f

vagrant-usb-up: ## bring up usb device-based vagrant-libvirt VM
	VAGRANT_VAGRANTFILE=Vagrantfile_usb vagrant up

vagrant-usb-destroy: ## destroy usb device-based vagrant-libvirt VM
	VAGRANT_VAGRANTFILE=Vagrantfile_usb vagrant destroy -f

help: ## display this help information
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
