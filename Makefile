CCRED=\033[0;31m
CCEND=\033[0m

.PHONY: build backup restore clean chezmoi help

help: ## Show this help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build / update mac setup
	 ansible-playbook -vv provisionMac.yml

backup: ## Backup mac configuration
	 ansible-playbook -vv provisionMac.yml

restore: ## Restore mac configuration
	 ansible-playbook -vv provisionMac.yml

clean:
	rm -rf /tmp ## Delete temporary files

install: ## Initial setup
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew analytics off
	echo "Update Git"
	brew install git
	echo "Install Ansible and prerequisites"
	brew install ansible
	brew install chezmoi
	rew install 1password-cli
	echo "**********************************************"
	echo "Installation complete"
	echo "**********************************************"
	@brew list

chezmoi: ## Chezmoi initial setup
	chezmoi init https://github.com/bhdicaire/dotFiles.git
