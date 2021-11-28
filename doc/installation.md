# Installation 
Installation introduction

This is being accomplish with the use of [homebrew](https://github.com/Homebrew/homebrew), [homebrew-cask](https://github.com/caskroom/homebrew-cask), and the Mac Apple Store CLI [(MAS)](https://github.com/mas-cli/mas).

<details>
<summary>1. Prepare</summary>
1. Prepare your future operating system

	1. Download it via the Mac Apple Store
	2. Create a bootable USB key
2. Backup your current configuration
	
	1. Update your dotFiles on [GitHub](https://github.com/bhdicaire/dotFiles) with [Chezmoi](https://github.com/twpayne/chezmoi)
```console
$ chezmoi update
```
	
	2. Update your BBEdit configuration on [GitHub](https://github.com/bhdicaire/bbeditSetup) with a Makefile
```console
$ cd ~/Library/Application Support/BBEdit
$ make
```
	
	3. Copy other configuration settings on an external drive with an Ansible playbook
```console
$ cd ~/macSetup
$ make backup
```
3. Clone your local hard drive (e.g., better be safe than sorry)

	1. Download SuperDuper
	2. Clone your local hard drive
4. Stop services and free licenses as required
	1. To be defined
5. Review the macSetup variables on [GitHub](https://github.com/bhdicaire/macSetup) for the new machine
	1. Computer name, users, and groups
```console
$ vi ~/macSetup/group_vars/all/default.yml
```
	2. AWS, Azure, and RSA keys secrets
```console
$ vi ~/macSetup/group_vars/secrets.yml
```

	3. Review the software to be installed during prepareMac:
```console
$ vi ~/macSetup/roles/prepareMac/brewTaps.yml
$ vi ~/macSetup/roles/prepareMac/macAppStoreConfig.yml
$ vi ~/macSetup/roles/prepareMac/packages.yml
$ vi ~/macSetup/roles/prepareMac/packagesConfig.yml
```
	4. Review the software to be installed during deployMac:
```console
$ vi ~/macSetup/roles/prepareMac/packages.yml
```
	5. Push the modifications to GitHub	
```console
$ git add *
$ git commit -M "Updated configuration for a new machine"
# git push
```


<details>
<summary>2. Install the operating system on a new machine</summary>
Install them on a new, empty machine with:
```
brew install chezmoi
brew install 1password-cli
chezmoi —init —apply https://github.com/bhdicaire/dotFiles.git
```
# delete unused fonts
Make backup copies of all System and Library fonts, first.
Boot to the Recovery partition and turn off System Integrity Protection. In Recovery mode, launch Terminal from the menu bar. Then enter:
csrutil disable
You should get a return message that SIP has been disabled. Then enter:
reboot
The Mac will restart. Once back at the normal desktop, you’ll be able to put any fonts in the trash you want to get rid of and empty the trash.
Return to Recovery mode and repeat as above, except turn SIP back on by entering:
csrutil enable
</details>

<details>
<summary>3. Manual activities</summary>

iCloud credential

make install
	
brew install chezmoi
brew install 1password-cli
chezmoi —init —apply https://github.com/bhdicaire/dotFiles.git

restore bbedit config	
	
</details>	

<summary>3. Ansible Playbook</summary>
make build
reboot
make build	
</details>

<details>
<summary>3. Ansible Playbook</summary>
make build	
</details>
