CCRED=\033[0;31m
CCEND=\033[0m

echo :=  "/opt/homebrew/bin/cowsay"

export ANSIBLE_FORCE_COLOR = 1
export PY_COLORS = 1
export PYTHONIOENCODING = UTF-8
export LC_CTYPE = en_US.UTF-8
export LANG = en_US.UTF-8

# https://serverfault.com/questions/1031491/display-ansible-playbook-output-properly-formatted
# https://stackoverflow.com/questions/50009505/ansible-stdout-formatting
export ANSIBLE_STDOUT_CALLBACK = unixy

.PHONY: build backup restore clean chezmoi help

# leave empty to disable
# -v - verbose;
# -vv - more details
# -vvv - enable connection debugging
DEBUG_VERBOSITY ?= -vvv

### Lint yaml files
lint: later
	$(xx) yamllint .
	$(xx) ansible-lint . --force-color
.PHONY: lint


help: ## Show this help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build / update mac setup
	 ansible-playbook -vv main.yml

backup: ## Backup mac configuration
	 ansible-playbook -vv backupConfig.yml

restore: ## Restore mac configuration
	 ansible-playbook -vv backupRestore.yml

clean:
	rm -rf /tmp ## Delete temporary files

info: ## Current setup statistics
	@clear
	@echo "**********************************************"
	@echo "user-friendly name for the system";scutil --get ComputerName
	@echo ""
	@echo "local (Bonjour) host name";scutil --get LocalHostName
	@echo ""
#	@echo "name associated with hostname(1) and gethostname(3)";scutil --get HostName;@echo ""
	@scutil --dns
	@echo "**********************************************"
	@ansible-galaxy role list
	@echo ""
	@ansible-galaxy collection list
	@echo "**********************************************"


install: ## Initial setup
	export PATH=/opt/homebrew/bin:$PATH
	sudo scutil --set ComputerName "Hal9000"
	sudo scutil --set LocalHostName Hal9000
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh > brew.sh
	chmod +x brew.sh
	/bin/bash -c ./brew.sh
	brew analytics off
  brew install cowsay
	# Disable “natural” (Lion-style) scrolling
	defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
	defaults write com.apple.finder AppleShowAllFiles true;killall Finder
	sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop
	/usr/sbin/systemsetup

	-getremotelogin
             Displays whether remote login (SSH) is on or off.

     -setremotelogin [-f] on | off
             Sets remote login (SSH) to either on or off.  Requires Full Disk Access privileges.  Important: If you turn off remote login, you won't be able to administer the server
             using remote command line tools and SSH.  To turn remote login back on, you'll need to connect a monitor and keyboard to the server to administer it locally.  Use
             "setremotelogin -f off" to suppress prompting when turning remote login off.

	$(echo) "Install Ansible and prerequisites"
	brew install ansible
	@ansible-galaxy install -r requirements.yml
	echo "Install prefered tools and prerequisites"
	brew install 1password
	brew install 1password-cli
	brew install bbedit
	brew install chezmoi
	brew install dockutil
	brew install duti
	brew install eza
	brew install git
	brew install gnu-tar
	brew install m-cli
	brew install mas
	brew install rsync
	brew install starship
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

galaxy: ## Update galaxy roles and collections
	@ansible-galaxy install -r requirements.yml
