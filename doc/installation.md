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
</details>
