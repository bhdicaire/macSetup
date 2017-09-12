# A Fresh Start with your Macintosh

## Requirements
The various configuration files are tested on OS X Sierra (10.12). Older operating system versions may work — your mileage may vary.

Download, *review*, then execute the scripts.

## Getting ready

As we will be formatting the hard drive which will wipe all information, it’s prudent to backup any important files along with your current profile.

For example, I’m using make backup to copy a few important files to a git folder on my Dropbox folder and pushing the update to my (GitHub repository)[https://github.com/bhdicaire/macSetup]. We can’t be to cautious.

### Creating a Mac OSX install disk

Let’s create a bootable USB drive with the OSX installer. Please use a USB drive without any important information as the drive will be erased by following steps.

Download El Capitan installer from the App store
Insert a 8GB or larger USB drive
Create Bootable OSX disk shell # Assumes disk is mounted as /Volumes/Untitled - update path if required sudo /Applications/Install\ OS\ X\ El\ Capitan.app/Contents/Resources/createinstallmedia --volume /Volumes/Untitled --applicationpath /Applications/Install\ OS\ X\ El\ Capitan.app --nointeraction

## Installing the operating system

1. Connect an ethernet adapter to accelerate the installation thus no wifi credential is on the computer
2. Install the current macOS version via cmd option r (internet rescue) or via a usb key.
   a. Enable location service
   b. Disable analytics and Siri
   c. Skip AppleID
   d, Create an admin user, in my case BHD
   e. Open the App Store and update all softwares
   f. Restart

## Hardening the operating system (e.g. a little) 
As you may know. the installation process use the primary account name, for example Benoît H. Dicaire's MacPro) as the computer's name and hostname. It's a good privacy practice to change it.

There are two modes for a firmware password: command and full. By default, the firmware password mode will be command, which means you'll be prompted for the password only if you boot from something other than the startup disk. If, for some strange reason, you want the mode to be full, it would mean you'd be prompted for a firmware password at every boot, regardless of what you're booting to.

3. Create a second account and 
  a. Create your regular user, in my case BHDicaire
  b. Modify login option
    1. Display login windows as Name and Password
    2. Disable fast user switching
  c. Open Terminal
4. Enable full disk encryption
	1. Let's manually seed entropy before enabling FileVault2
		* cat > /dev/random
		* [Type random letters for a while, then press Control-D]
		* sudo fdesetup enable
  e. Copy the recovery key via AirDrop
4. Enable firmware protection
  a. sudo firmwarepasswd -setpasswd
  c. Restart
5. Prepared the environment
  a. Login as the regular user
  b. Change the computer name and hostname
  	1. sudo scutil --set ComputerName "Hal"
		2. sudo scutil --set LocalHostName hal
	c. Enable the firewall
	sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
	sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
	sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
	sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned off
	sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp off
	sudo pkill -HUP socketfilterfw
	
  b. You’re ready to start the (ansible installation)[https://github.com/bhdicaire/macSetup/README.md]

For your information ...
 * checks to see if the firmware password is set.
		* sudo firmwarepasswd -check
	* allows you to verify you have the correct password (without rebooting).
		sudo firmwarepasswd -verify
	* deletes the firmware password. You'll need the current one to delete it, of course.
		sudo firmwarepasswd -delete

## Author

Benoît H. Dicaire, http://github.com/BHDicaire, @BHDicaire, BH@Dicaire.com, http://BHDicaire.com/

### About

I help organizations facing difficult strategic decision-making.

I am a freelance security expert and a keynote speaker in French and English. Over the last 25 years, I have led consulting engagements for well-known companies throughout North America.

I'm [available for hire](http://dicaire.com/).  I’d be pleased to discuss your requirements.