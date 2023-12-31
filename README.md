![logo](doc/logo.png)

[![GitHub license](https://img.shields.io/github/license/bhdicaire/macSetup)](https://github.com/bhdicaire/macSetup/blob/main/LICENSE) [![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](code_of_conduct.md) [![All Contributors](https://img.shields.io/badge/all_contributors-3-orange.svg?color=ee8449&style=flat-square)](#contributors)

macSetup is an ansible playbook to automate macOS installation & configuration:
  * Add users, groups, and shell based on variables defined in [defaults.yml](group_vars_/all/defaults.yml), [host.yml](group_vars_/all/host.yml) and [secrets.yml](group_vars_/secrets.yml)
   * Install all [packages](group_vars_/all/packages.yml) via [homebrew](https://brew.sh), [Mac App Store CLI](https://github.com/mas-cli/mas) and downloaded DMG
 * Add printers
 * user preferences
    * activity Monitor
    * dock
    * file type association
    * finder
    * login components
    * photos
    * safari
    * spotlight
    * terminal
    * timeMachine

My objective is to work at the command line and automate so I don't have to document extensively.

## What problem does it solve and why is it useful?

You’ve been there too — setting up a new computer can be an ad-hoc, manual, and time-consuming process. Especially if you have a *regular* MacBook, a developper workstation and a Mac Mini acting as your local file server.

I'm not a fan of upgrade or the migration assistant as too much scruff from previously tested applications get carry over. I prefer a clean slate, complexity is the enemy of security.

I wasn't happy with any of the automated setup that I came across. They were either overly complex or were missing features that I really wanted.

## Pre requisites

Ensure that you have identified _all_ the applications on your current Mac:
 * sources such as [homebrew](https://brew.sh), [Mac App Store](https://github.com/mas-cli/mas) or a downloaded installation file
 * licensed file and key – some applications require that you uninstall them or deallocate the licence first
 * Backup  your user preferences and settings using the backup playbook

## Installation

I'm currently using [Sonoma](https://www.apple.com/ca/macos/sonoma/), older macOS versions may work.

1. Connect an ethernet adapter to accelerate the files transfer
2. Boot the new Mac and answer a few questions:
    A. Language: English
    B. Country: Canada
    C. Accessibility: _not now_
    D. Migration Assistant: _not now_
3. Sign-in with your apple ID and accept the iCloud Terms & Conditions
4. Create a computer account
5. Install the developer tools (xcode) by opening terminal and typing `git`, the user interface will prompt you to download and install the command line developer tools
6. Clone the macSetup git repository on your Mac `git clone https://github.com/bhdicaire/macSetup` via terminal
7. Install homebrew and the required software components
    1. `cd macSetup`
    2. `make install`
8. Modify the configuration files with a built-in text editor such as `vi`, don't worry the playbook will install [BBEdit](https://www.barebones.com/products/bbedit/)
    * ./group_vars_/all/defaults.yml
    * ./(group_vars_/all/host.yml
    * ./group_vars_/secrets.yml
    * ./group_vars_/all/packages.yml
11. Go get a cup of coffee because you're NOT done, Vodka is also fine

12. Add and commit your macSetup configuration to a Git repository
13. The following tasks must be performed manually as I have yet to find a way to automate them:
    - [ ] Microsoft Office 2016
    - [ ] App Store - restore In-App Purchases for Marked2
    - [ ] [SetApp](https://setapp.com) applications
      * [Bartender](https://setapp.com/apps/bartender)
      * [Bike](https://setapp.com/apps/bike-outliner)
      * [BusyContact](https://setapp.com/apps/busycontacts)
      * [CleanShot X](https://setapp.com/apps/cleanshot)
      * [Forklift](https://setapp.com/apps/forklift)
      * [Gemini](https://setapp.com/apps/gemini)
      * [Hookmark](https://setapp.com/apps/hookmark)
      * [HoudahSpot](https://setapp.com/apps/houdahspot)
      * [iStat Menus](https://setapp.com/apps/istat-menus)
      * [Marked](https://setapp.com/apps/marked)
      * [Merlin Project Express](https://setapp.com/apps/merlin-project-express)
      * [OpenIN](https://setapp.com/apps/openin)
      * [PDF Squeezer](https://setapp.com/apps/pdf-squeezer)
      * [Permute](https://setapp.com/apps/permute)
      * [Pulltube](https://setapp.com/apps/pulltube)
      * [Souver](https://setapp.com/apps/soulver)


Refer to the [documentation folder](doc/how.md) and the code for more information.

## Contributions

I'm really glad you're reading this, because I need help to *fully* automate macOS installation and configuration using Ansible. Please fork, fix, enhance, and send pull requests.

[Contributions](doc/CONTRIBUTING.md) are welcome! I recognize [all types](https://allcontributors.org/docs/en/emoji-key) based on the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Please note that this project is released with a [Contributor Code of Conduct](doc/CODE-OF-CONDUCT.md). By participating in this project you agree to abide by its terms.

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/bhdicaire"><img src="https://avatars.githubusercontent.com/u/1316765?v=4?s=100" width="100px;" alt="Benoît H. Dicaire"/><br /><sub><b>Benoît H. Dicaire</b></sub></a><br /><a href="https://github.com/bhdicaire/vanityURLs/commits?author=bhdicaire" title="Code">💻</a> <a href="https://github.com/bhdicaire/vanityURLs/commits?author=bhdicaire" title="Documentation">📖</a> </td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

## Related
 * [mac tools](https://github.com/bhdicaire/macTools) – Ansible roles for macOS automation

## Licence
**macSetup** is Copyright 2018 Benoît H. Dicaire and [licensed under the MIT licence](LICENCE).
