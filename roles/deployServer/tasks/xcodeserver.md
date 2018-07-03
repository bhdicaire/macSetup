# ansible-xcodeserver
This is an ansible playbook that will install and configure Server.app, Xcode.app and it will enable the Xcode service in Server.app.

For now these are the basic steps to get up and running. I'll have more detailed instructions soon.

## 1. Download .pkg Installers for Server.app and Xcode.app
But wait, these are only available in the Mac App Store? There is a wonderful way to turn on debug mode in the app store
and it will allow you to retrieve the .pkg installers used by the Mac App Store. Rich Trouton (Der Flounder) wrote a great
[blog post detailing the instructions](https://derflounder.wordpress.com/2013/08/22/downloading-apples-server-app-installer-package/)

## 2. Setup the "hosts" Inventory File
In this repo there is a file called "hosts" that needs to be modified to use with ansible. You can skip this if you're going
to use the local provisioning capabilities of ansible (more details later).

Open the `hosts` file with your favorite text editor and replace `x.x.x.x` with the IP address or DNS name of the Mac that
you will be running ansible on. Replace `macuser` the name the user that has SSH access for ansible to connect with. This user
must be an admin on the system since most of this requires the use of `sudo`.

## 3. Update the Filenames of Your .pkg Installers
This playbook uses a`vars_files` with the paths `./xcode.pkg` and `serverapp.pkg`. Rename your packages to match and move them
to the same directory as the playbook.

## 4. Run With Hosts File and Vars File
```
ansible-playbook -i hosts --ask-pass --ask-become-pass xcodeserver.yml -e@pkgvars.yml
```

**THIS WILL TAKE A VERY LONG TIME, POSSIBLY 30 MINUTES OR MORE**
