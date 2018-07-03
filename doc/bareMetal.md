# Bare metal installation — A Fresh Start with your Macintosh 

Let’s create a bootable USB drive with the OSX installer. If you prefer to install the operating system via *internet rescue*, you may skip the section.

Please use a 8GB or larger USB drive without any important information as the drive will be erased by following steps.

1. Download the High Sierra installer from the App store
2. Insert the USB drive
3. Validate the volume name and either rename the drive as ``Untitled``` or customize  step #4
4. Create a bootable macOS disk shell # Assumes disk is mounted as /Volumes/Untitled - update path if required sudo /Applications/Install\ OS\ X\ El\ Capitan.app/Contents/Resources/createinstallmedia --volume /Volumes/Untitled --applicationpath /Applications/Install\ OS\ X\ El\ Capitan.app --nointeraction
5. Eject the USB key
6. test it :grin:

## Getting ready 
> "There are two kinds in the world, those who have lost data, and those who will." —  Mike Epstein
Your data really isn't safe unless you're backing it up with lots of redundancy. You can't go wrong with Scott Hanselman's [computer backup rules](http://www.hanselman.com/blog/TheComputerBackupRuleOfThree.aspx): 

1. **Three copies of anything you care about** — Two isn't enough if it's important.
2. **Two different formats** — a Dropbox account & some DVDs, an external hard drive and an online backup solution, etc.
3. **One off-site backup** — If the house burns down, how will you get your memories back?

Ensure that all your configuration items are stored according to the [configuration management](https://github.com/bhdicaire/macSetup/doc/configManagement.md) to automate the installation and configuration process. 
## Installing the operating system

1. Connect an ethernet adapter to accelerate the installation thus no wifi credential is on the computer
2. Install the current macOS version via cmd option r (internet rescue) or via a usb key.
   i. Enable location service
   ii. Disable analytics and Siri
   iii. Skip AppleID
   iv, Create an admin user, in my case BHD
   v. Open the App Store and update all softwares
   vi. Restart

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
	


For your information ...
 * checks to see if the firmware password is set.
		* sudo firmwarepasswd -check
	* allows you to verify you have the correct password (without rebooting).
		sudo firmwarepasswd -verify
	* deletes the firmware password. You'll need the current one to delete it, of course.
		sudo firmwarepasswd -delete


OS X updates and Xcode Command Line Tools</summary>

The fastest way to find {command options|code pieces} you need :)

  b. You’re ready to start the (ansible installation)[https://github.com/bhdicaire/macSetup/README.md]
  
As we will be formatting the hard drive which will wipe all information, it’s prudent to backup any important files along with your current profile.

For example, I’m using make backup to copy a few important files to a git folder on my Dropbox folder and pushing the update to my (GitHub repository)[https://github.com/bhdicaire/macSetup]. We can’t be to cautious.
## Author

Benoît H. Dicaire, http://github.com/BHDicaire, @BHDicaire, BH@Dicaire.com, http://BHDicaire.com/

