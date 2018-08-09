![macSetup logo](https://github.com/bhdicaire/macSetup/raw/master/doc/logo.png)

You’ve been there too — setting up a new computer can be an ad-hoc, manual, and time-consuming process.

I wasn't happy with any of the automated setup that I came across. They were either overly complex or were missing features that I really wanted.

My objective is to fully automate macOS installation and configuration using Ansible. Lots of stuff in here you probably don't need, and some that needs personalization for your system ... So feel free to fork, and customize.

## What problem does it solve and why is it useful?

Setup a Mac up with everything configured properly with easy-to-understand instructions that automate the installation and configuration from the [bare metal](https://github.com/bhdicaire/macSetup/blob/master/doc/bareMetal.md).

### Modules
I have currently implemented the following modules.


<details>
<summary>Software installation</summary>

 This is being accomplish with the use of [homebrew](https://github.com/Homebrew/homebrew), [homebrew-cask](https://github.com/caskroom/homebrew-cask), and the Mac Apple Store CLI [(MAS)](https://github.com/mas-cli/mas).

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

---
## Install

The various configuration files are tested on OS X High Sierra (10.13). Older operating system versions may work — your mileage may vary, so download, review, and then execute the scripts.

### Step 0: Prepare your computer
Refer to my [guide](https://github.com/bhdicaire/macSetup/blob/master/prepare.md) for this important step.
 **You need to login in the app**

#### Software Deactivation

The following software should be deactivated before re-installing macOS:
* TBD
### Step 1: Fetch the bootstrap script
Open the terminal window:
Install git
```
$ git clone https://github.com/
sh -c "$(curl -fsSL https://raw.githubusercontent.com/bhdicaire/macSetup/master/install.sh)"```

### Step 2: Run the bootstrap
Download, *review*, then execute the script:

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
