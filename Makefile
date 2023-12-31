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

ssh: ## Adding key to the ssh-agent
	eval "$(ssh-agent -s)"
	ssh-add -K ~/.ssh/githubCom

install: ## Initial setup
	export PATH=/opt/homebrew/bin:$PATH
	sudo scutil --set ComputerName "Hal9000"
	sudo scutil --set LocalHostName Hal9000
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh > brew.sh
	chmod +x brew.sh
	/bin/bash -c ./brew.sh
	brew analytics off
	brew install cowsay
	brew install bash
	brew install zsh
	brew install gnu-tar
	# Disable “natural” (Lion-style) scrolling
	defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
	sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop
	echo "Update Git"
	brew install git
	echo "Install Ansible and prerequisites"
	brew install ansible
	ansible-galaxy install -r requirements.yml
        echo "Install prefered tools"
	brew install chezmoi
	brew install 1password-cli
	brew install 1password
	@osascript -e 'tell application "Finder" to empty the trash' 2> '/dev/null' || true
	@echo "**********************************************"
	cowsay "Installation complete"
	@echo "**********************************************"
	@brew list
	@echo "**********************************************"
	@echo "user-friendly name for the system";scutil --get ComputerName
	@echo ""
	@echo "local (Bonjour) host name";scutil --get LocalHostName
	@echo ""
#	@echo "name associated with hostname(1) and gethostname(3)";scutil --get HostName;@echo ""
	@scutil --dns
	@ansible-galaxy role list
	@echo ""
	@ansible-galaxy collection list
	@echo "**********************************************"

chezmoi: ## Chezmoi initial setup
	chezmoi init https://github.com/bhdicaire/dotFiles.git
