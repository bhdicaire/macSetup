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



### Step 0: Prepare your computer
Refer to my [guide](https://github.com/bhdicaire/macSetup/blob/master/prepare.md) for this important step.

#### Software Deactivation

The following software should be deactivated before re-installing macOS:
* TBD
### Step 1: Fetch the bootstrap script

[https://github.com/bhdicaire/macSetup/](https://github.com/bhdicaire/macSetup/)

    ~$ git clone https://github.com/

### Step 2: Run the bootstrap
Download, *review*, then execute the script:
    ~$ git clone https://github.com/

### Step 3: Reboot your computer

It is strongly suggested that you reboot your Mac after the first run
of this tool.

Answer a couple of questions ...

Run the playbook a second time, to get the configurations.

### Step 4: Go get a cup of coffee because you're NOT done

I prefer an espresso myself. Vodka is also fine.

The following tasks must be performed manually as I have yet to find a way to
automate them:
- [ ] Microsoft Office 2016
- [ ] App Store - restore In-App Purchases for Marked2

## Author

Benoît H. Dicaire, http://github.com/BHDicaire, @BHDicaire, BH@Dicaire.com, http://BHDicaire.com/


### About

I help organizations facing difficult strategic decision-making.

I am a freelance security expert and a keynote speaker in French and English. Over the last 25 years, I have led consulting engagements for well-known companies throughout North America.

I'm [available for hire](http://dicaire.com/).  I’d be pleased to discuss your requirements.
