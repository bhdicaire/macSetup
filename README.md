# macSetup
Ansible code to build my Mac from scratch

## Introduction

My objective is to fully automate macOS installation and configuration using Ansible. Lots of stuff in here you probably don't need/ want, and some that needs personalization for your system.

Some fun stuff, though, feel free to fork, fix, enhance, and send pull requests.

## Requirements
The various configuration files are tested on OS X Sierra (10.12). Older operating system versions may work — your mileage may vary  ;)

Setting up a new computer can be an ad-hoc, manual, and time-consuming process.
This repo aims to simplify the process with easy-to-understand instructions and dotfiles/scripts thatautomate the setup of:
These are a series of scripts. Many are derived from prior works of open source, but some original URLs have been lost. Please point out any original art URLs and they will be added. I always strive to give credit to prior art authors.


### What problem does it solve and why is it useful?
I wasn't happy with any of the automated setup that I came across. They were either overly complex or were missing features that I really wanted.
## Modules
I have currently implemented the following modules.

Here's what you get with this role:
<details>
<summary>OS X updates and Xcode Command Line Tools</summary>

The fastest way to find {command options|code pieces} you need :)

</details>

<details>
<summary>Unix Package Installation</summary>
This is being accomplish with the use of [homebrew](https://github.com/Homebrew/homebrew).
</details>
<details>
<summary>Desktop Application Installation</summary>
This is being performed with the use of [homebrew-cask](https://github.com/caskroom/homebrew-cask).
</details>
<details>
<summary>Appstore Application Installation</summary>
This is being performed with the use of [MAS](https://github.com/).
**You need to login in the app**
</details>
<details>
<summary>Configuration Files & Symlinks</summary>
Any files and folders that are to be copied or symlinked, including app settings, licenses and dotfiles.
</details>
<details>
<summary>Dock Configuration</summary>
Automatic building of the Dock using [dockutil](https://github.com/kcrawford/dockutil).
</details>
<details>
<summary>Default Apps</summary>
File associations for various applications using [duti](https://github.com/moretension/duti).
</details>
<details>
<summary>Startup Setup</summary>
Ensures that the required items start on startup using [loginitems](https://github.com/OJFord/loginitems).
</details>
<details>
<summary>Terminal Customisatio</summary>
Setting up the Terminal using JXA.
</details>
<details>
<summary>H</summary>
H
</details>

<details>
<summary>OS X default</summary>

[Apple Defaults](https://developer.apple.com/documentation/corefoundation/preferences_utilities)
* **macOS & Software Defaults**: Updating of plist properties for various
  aspects of macOS and software configuration.  This uses a custom plist module
  which allows for complex updates of plist files far beyond the defaults
  command.  The plist module is a modified version of
  [Matthias Neugebauer's plist module](https://github.com/mtneug/ansible-modules-plist).
</details>

<details>
<summary>Developer tools</summary>

Vim, bash, tab completion, curl, git, GNU core utils, Python, Ruby, etc
Developer apps: iTerm2, Sublime Text, Atom, VirtualBox, Vagrant, Docker, Chrome, etc
Node.js, JSHint, and Less
</details>
<details>
<summary>Cloud services</summary>

Amazon Web Services (Boto, AWS CLI, S3cmd,
Azure

</details>
:
<details>
<summary>H</summary>
</details>
https://groups.google.com/forum/#!forum/ansible-project - for user questions, tips, and tricks
https://groups.google.com/forum/#!forum/ansible-devel - for strategy, future planning, and questions about writing code

- [x] this is a complete item
- [ ] this is an incomplete item
- [x] @mentions, #refs, [links](),

---

## Install

Download, *review*, then execute the script:

a
It is strongly suggested that you reboot your Mac after the first run
of this tool.

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

If you wish to install the various sample libraries and sound packs, connect
one of your backup drives and run the following:

```bash
./extras/samples.py
```


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





## Author

Benoît H. Dicaire, http://github.com/BHDicaire, @BHDicaire, BH@Dicaire.com, http://BHDicaire.com/


### About

I help organizations facing difficult strategic decision-making.

I am a freelance security expert and a keynote speaker in French and English. Over the last 25 years, I have led consulting engagements for well-known companies throughout North America.

I'm [available for hire](http://dicaire.com/).  I’d be pleased to discuss your requirements.



.. |debops_logo| image:: https://debops.org/images/debops-small.png

.. _Gitlab: https://github.com/debops/ansible-gitlab
.. _GitlabCI: https://github.com/debops/ansible-gitlab_ci
