# macSetup
Ansible code to build my Mac from scratch

## Introduction

|CII Best Practices|

.. |CII Best Practices| image:: https://bestpractices.coreinfrastructure.org/projects/237/badge
   :target: https://bestpractices.coreinfrastructure.org/projects/237

   Here are a few services that are available
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
https://raw.githubusercontent.com/drybjed/debops-playbooks/master/README.rst
**Fully loaded ready to go applications**

+---------+-----------+-----------+-----------+-----------+----------+----------+
| GitLab_ | GitLabCI_ | Etherpad_ | DokuWiki_ | ownCloud_ | phpIPAM_ | Mailman_ |
+---------+-----------+-----------+-----------+-----------+----------+----------+

**Databases**

+-------------+----------+--------+------------+----------------+
| PostgreSQL_ | MariaDB_ | Redis_ | Memcached_ | Elasticsearch_ |
+-------------+----------+--------+------------+----------------+
My objective is to fully automate macOS installation and configuration using Ansible. Lots of stuff in here you probably don't need/ want, and some that needs personalization for your system.

Some fun stuff, though, feel free to fork, fix, enhance, and send pull requests.

 mostly personal taste config. feel free to take what you like.
## Requirements
The various configuration files are tested on OS X Sierra (10.12). Older operating system versions may work — your mileage may vary.

These are a series of scripts. Many are derived from prior works of open source, but some original URLs have been lost. Please point out any original art URLs and they will be added. I always strive to give credit to prior art authors.

This was my first real foray into automation with Ansible, hope it’s useful to others.
> This is a quote

Horizontal rule is created using --- on a line by itself.

```python
# The Greeter class

add .aws // https://github.com/donnemartin/dev-setup/tree/master/.aws
- [x] this is a complete item
- [ ] this is an incomplete item
- [x] @mentions, #refs, [links](),
Setting up a new developer machine can be an ad-hoc, manual, and time-consuming process. This repo aims to simplify the process with easy-to-understand instructions and dotfiles/scripts thatautomate the setup of:

OS X updates and Xcode Command Line Tools
OS X defaults geared towards developers [Apple Defaults](https://developer.apple.com/documentation/corefoundation/preferences_utilities)
Developer tools: Vim, bash, tab completion, curl, git, GNU core utils, Python, Ruby, etc
Developer apps: iTerm2, Sublime Text, Atom, VirtualBox, Vagrant, Docker, Chrome, etc
Python data analysis: IPython Notebook, NumPy, Pandas, Scikit-Learn, Matplotlib, etc
Big Data platforms: Spark (with IPython Notebook integration) and MapReduce
Cloud services: Amazon Web Services (Boto, AWS CLI, S3cmd, etc) and Heroku
Common data stores: MySQL, PostgreSQL, MongoDB, Redis, and Elasticsearch
Javascript web development: Node.js, JSHint, and Less
Android development: Java, Android SDK, Android Studio, IntelliJ IDEA
You can also automate the process by running a single setup script to install and configure specified sections.

If you continue seeing any problems related to this issue, or if you have any further questions, please let us know by stopping by one of the two mailing lists, as appropriate:

https://groups.google.com/forum/#!forum/ansible-project - for user questions, tips, and tricks
https://groups.google.com/forum/#!forum/ansible-devel - for strategy, future planning, and questions about writing code

## Done
I have currently implemented the following:
What problem does it solve and why is it useful?

I wasn't happy with any of the nginx roles that I came across. They were either overly complex or were missing features that I really wanted.

Here's what you get with this role:


* **macOS & Software Defaults**: Updating of plist properties for various
  aspects of macOS and software configuration.  This uses a custom plist module
  which allows for complex updates of plist files far beyond the defaults
  command.  The plist module is a modified version of
  [Matthias Neugebauer's plist module](https://github.com/mtneug/ansible-modules-plist).
* **Unix Package Installation**: This is being accomplish with the use of
  [homebrew](https://github.com/Homebrew/homebrew).
* **Desktop Application Installation**: This is being performed with the use
  of [homebrew-cask](https://github.com/caskroom/homebrew-cask).
* **Appstore Application Installation**: This is being performed with the use
  of [MAS](https://github.com/).  You need to login in the app ...
* **Configuration Files & Symlinks**: Any files and folders that are to be
  copied or symlinked, including app settings, licenses and dotfiles.
* **Dock Configuration**: Automatic building of the Dock using
  [dockutil](https://github.com/kcrawford/dockutil).
* **Default Apps**: File associations for various applications using
  [duti](https://github.com/moretension/duti).
* **Startup Setup**: Ensures that the required items start on startup using
  [loginitems](https://github.com/OJFord/loginitems).
* **Terminal Customisation**: Setting up the Terminal using JXA.

## Install

Download, *review*, then execute the script:

ansible-playbook dogbert.yml -i inventory --list-tasks
ansible-playbook dogbert.yml -i inventory --verbose

elliotweiser.osx-command-line-tools

Collection of useful scripts for doing odd things

1. Connect an ethernet adapter to accelerate the installation thus no wifi credential is on the computer
2. Install the current macOS version via cmd option r (internet rescue) or via a usb key.
   a. Enable location service
   b. Disable analytics and Siri
   c. Skip AppleID
   d, Create an admin user, in my case BHD
   e. Open the App Store and update all softwares
   f. Restart
3. Create a second account and let’s encrypt the internal HD
  a. Create your regular user, in my case BHDicaire
  b. Modify login option
    1. Display login windows as Name and Password
    2. Disable fast user switching
  c. Open Terminal
  d. sudo fdesetup enable
  e. Copy the recovery key via AirDrop
  f. Restart
4. Enable firmware protection
  a. [Command] R
  b. Utilities --> Firmware Password Utility
  c. Restart
5. Prepared the environment
  a. Login as the regular user
  b. Open Terminal
  c. git --version
  d. Install the command line developper tools as proposed by the Operating System :)
  e. git --version
  f. Open app store and login with your Apple ID
  g. git clone https://github.com/bhdicaire/macSetup.git
  h. cd macSetup
  i. ./macSetup.sh

Your last mac-setup run will be saved to ~/mac-setup.log. Read through it to see if you can debug the issue yourself.

Now, run the following in your Terminal to use my configuration:

curl --remote-name https://github.com/bhdicaire/mac-setup/blob/master/run less mac
> sh mac 2>&1 | tee ~/mac-setup.log

It is strongly suggested that you reboot your Mac after the first run
of this tool.

If you wish to install the various sample libraries and sound packs, connect
one of your backup drives and run the following:

```bash
./extras/samples.py
```

## Can I accelerate the process?

1. Copy a Homebrew cache backup to `~/Library/Caches/Homebrew`
2. Copy App Store apps that you have previously downloaded to `/Applications`
3. Copy `System Automation` containing various settings and licenses to `~/Documents`
4. Install Apple's Command Line Tools manually to avoid them being re-downloaded

## Manual Tasks

The following tasks must be performed manually as I have yet to find a way to
automate them.

### Installation & Configuration (macOS)

* **Finder**: Setup sidebar containing favourites
* **Services**: In System Preferences / Keyboard / Services, enable 'New Terminal at Folder' and 'New Terminal Tab at Folder'
* **Screen Saver**: Set the screen saver to 'Flurry'
* **Notification Centre**: Set the order of items and allow permission
* **Safari**: Install extensions (1Password and Adblock Plus)
* **App Store Login Items**: Start App Store menubar apps and set them to start
  at login (AppCleaner and OneDrive)
* **Keyboard Shortcuts**: Under System Preferences / Keyboard:
    - Set 'Show Launchpad' to F14 under 'Launchpad & Dock'
    - Set 'Show Notification Center' to F15 under 'Mission Control'
    - Set 'Show Desktop' to F13 under 'Mission Control'
    - Disable 'Show Dashboard' under 'Mission Control'

### Installation & Configuration (General)

* **Dropbox**: Disable camera uploads

### Manual Licensing
#### App Store - restore In-App Purchases
* Marked2


Add
* **Microsoft Office**

## Software Deactivation

The following software should be deactivated before re-installing macOS:

* TBD

## References

SIt on the shoulder of giant

https://github.com/fgimian/macbuild

### Projects

* [mac-dev-playbook](https://github.com/geerlingguy/mac-dev-playbook)
* [ansible-modules-plist](https://github.com/mtneug/ansible-modules-plist)
* [legacy-common](https://github.com/osxc/legacy-common)
* [custom-ansible-osx](https://github.com/mtneug/custom-ansible-osx)



## Author

Benoît H. Dicaire, http://github.com/BHDicaire, @BHDicaire, BH@Dicaire.com, http://BHDicaire.com/


### About

I help organizations facing difficult strategic decision-making.

I am a freelance security expert and a keynote speaker in French and English. Over the last 25 years, I have led consulting engagements for well-known companies throughout North America.

I'm [available for hire](http://dicaire.com/).  I’d be pleased to discuss your requirements.

5minbootstrap
=============

Bootstrap and secure your server in 5 minutes flat.  A riff on this excellent post:

http://plusbryan.com/my-first-5-minutes-on-a-server-or-essential-security-for-linux-servers


There's a blog post that I wrote to go along with this.  Check it out!

http://practicalops.com/my-first-5-minutes-on-a-server.html


TL;DR
=====

## Step 1: Set the root password

Run:

    yourmachine$ ssh root@server

Enter the initial root password from your hosting provider, then run:

	root@server# passwd


## Step 2: Fetch the bootstrap recipe

[https://github.com/phred/5minbootstrap/](https://github.com/phred/5minbootstrap/)

    yourmachine ~$ git clone https://github.com/phred/5minbootstrap.git
	yourmachine ~$ cd 5minbootstrap


## Step 3: Edit hosts.ini

Ansible needs to know about the servers you want to manage.  There is
no fancy central database, just a text file with a list of
servers.  Oh, it's called an "inventory file."

Edit the `hosts.ini` that came with the repository.  Replace
`127.0.0.1` with your IP address, and `:2222` with your SSH port.

    [newservers]
	127.0.0.1:2222


## Step 4: Update the SSH public key.

    yourmachine ~/5minbootstrap$ cp ~/.ssh/id_dsa.pub ./fred.pub

For simplicity I provided my public key in the repo.  Unless you want
to grant me login access to your server, you probably want to change
that. :-)


## Step 5: Run the playbook

This is the needed invocation *for Vagrant*:

    yourmachine ~/5minbootstrap$ ansible-playbook -i hosts.ini bootstrap.yml --ask-pass --sudo

If you are logging into a fresh Linode, or another sytem where you only have the `root` user, you need to run this command:

    yourmachine ~/5minbootstrap$ ansible-playbook -i hosts.ini bootstrap.yml --user root --ask-pass

## Step 6: Go get a cup of coffee because you're DONE.

I prefer hand-ground French pressed coffee myself.  Tea is also fine.

### Blog Posts

* [Automating your development environment with Ansible](http://www.nickhammond.com/automating-development-environment-ansible/)
* [How to automate your Mac OS X setup with Ansible](https://blog.vandenbrand.org/2016/01/04/how-to-automate-your-mac-os-x-setup-with-ansible/)
* [Using Ansible to automate OSX installs via Superlumic](http://vanderveer.be/2015/09/27/using-ansible-to-automate-osx-installs-via-superlumic.html)
* [How to Bootstrap a new OS X Environment with Ansible](http://flounderedge.com/bootstrap-new-os-x-environment-ansible/)
* [Automation of Installation on Mac w/ Ansible](https://medium.com/@hackyGQ/automation-of-installation-on-mac-w-ansible-21354cce0d7b#.j7rujxwgc)

.. |debops_logo| image:: https://debops.org/images/debops-small.png

.. _Gitlab: https://github.com/debops/ansible-gitlab
.. _GitlabCI: https://github.com/debops/ansible-gitlab_ci
