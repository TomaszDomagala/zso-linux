all: help

ROOT_DIR=$(shell pwd)
LINUX_DIR=linux-5.16.5

.PHONY: copy-config
copy-config: ## copy config to linux dir
	@echo "Copying config files..."
	@cp $(ROOT_DIR)/config $(ROOT_DIR)/linux-5.16.5/.config
	@cd $(ROOT_DIR)/linux-5.16.5 && make oldconfig

.PHONY: compile-kernel
compile-kernel: ## compile kernel
	@echo "Compiling kernel..."
	@cd $(ROOT_DIR)/linux-5.16.5 && make -j$(shell nproc)

.PHONY: upload-kernel
upload-kernel: ## Copies kernel to the vm
	@echo "Uploading kernel to the vm..."
	@rsync -arvz -rsh=ssh -e 'ssh -p 2222' $(LINUX_DIR) root@localhost:/root

.PHONY: install-kernel
install-kernel: ## Installs kernel on the vm
	@echo "Installing kernel on the vm..."
	@ssh -p 2222 root@localhost "cd ~/linux-5.16.5 && make modules_install && make install"


.PHONY: help
help:
	@awk -F ':|##' '/^[^\t].+?:.*?##/ {printf "\033[36m%-25s\033[0m %s\n", $$1, $$NF}' $(MAKEFILE_LIST)
