PACKER ?= packer


.PHONY: all clean

all: custom-cloudimg.tar.gz

lint:
	packer validate .
	packer fmt -check -diff .

format:
	packer fmt .

seeds-flat.iso: user-data-flat meta-data
	cloud-localds $@ $^

OVMF_VARS.fd: /usr/share/OVMF/OVMF_VARS.fd
	cp -v $< $@

custom-cloudimg.tar.gz: clean
	sudo ${PACKER} init . && sudo PACKER_LOG=1 ${PACKER} build -only='cloudimg.*' .

clean:
	sudo ${RM} -rf output-* custom-*.gz

CUSTOM_PKGS:=${wildcard packages/*.deb}

packages/custom-packages.tar.gz: ${CUSTOM_PKGS}
ifeq ($(strip $(CUSTOM_PKGS)),)
	tar czf $@ -C packages -T /dev/null
else
	tar czf $@ -C packages ${notdir $^}
endif

.INTERMEDIATE: OVMF_VARS.fd
