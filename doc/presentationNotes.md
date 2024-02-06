Prerequisites

A blank computer running macOS 12.6 (Monterrey)
Sign-in into the Mac App Store
Add the Terminal app to the Full Disk Access section on Security And Privacy
Install the Xcode Command Line Tools: sudo xcode-select --install

Additionally, on Apple Silicon computers you must enable Reduced Security ahead of running this to allow the Rogue Amoeba apps to install.
https://rogueamoeba.com/support/knowledgebase/?showArticle=ACE-StepByStep

Limitations

This role is not meant to be run against remote machines
This role will prompt for the logged in user's password in order to use sudo for the Homebrew steps
Logging out after the role completes is recommended as some settings don't apply until a new login occurs

Reusability

The playbooks are heavily personalized and customized to my needs, but in theory they can meet the needs of others through forking this repository and modifying the group_vars variables, and other various configs in files and templates to suit your needs.

I try to stay up-to-date with the latest Ansible practices, and I try to stay consistent with my own style choices. But, I'm always looking to improve the playbooks in ways that are efficient, clear, and straight-forward.

The bootstrap playbook, as detailed in the README, assumes no prior knowledge of the local workstation, so it's geared towards running locally and not remotely.

I use Homebrew to manage all my packages and apps. It may not be as robust as a Linux package manager but it's made the terminal experience in Mac bearable for me. I love the OS and the ecosystem very much, but the command line tools leave a lot to be desired.

I will say that it can sometimes be annoying to chase down OS configs that change from release to release, as I apply a long list at bootstrap.

I'm happy to share any other info about Ansible or my specific setup! Hopefully this helps or inspires others!

vanityURLs
Note: By default, zero assumes your configuration directory is located in one of following locations. This can be changed with the --directory flag.

$XDG_CONFIG_HOME/zero/dotfiles
$HOME/.config/zero/dotfiles

---
https://github.com/zero-sh/zero.sh <-- readme stuff
https://austincloud.guru/2020/05/07/automating-macos-configuration/

https://spaceship-prompt.sh

mdls -name kMDItemContentType PATH_OF_AN_EXISTS_MD_FILE
Liste des utoilistauires dans README.

https://developer.apple.com/documentation/foundation/userdefaults

https://git.herrbischoff.com/awesome-macos-command-line/about/
https://git.herrbischoff.com/awesome-macos-command-line/about/#contacts

INspiratiojns:

*  https://github.com/topics/osx-setup
https://github.com/lotyp/dotfiles
* https://github.com/wayofdev/ansible-role-homebrew/
* https://github.com/wayofdev/ansible-role-dock


PLus tard :
https://github.com/wayofdev/ansible-role-dnsmasq/ & https://thekelleys.org.uk/dnsmasq/doc.html
https://github.com/renemarc/dotfiles

--> https://github.com/wayofdev/ansible-role-dotfiles/blob/master/.pre-commit-config.yaml

check stuff installed: pkgutil --pkg-info=com.apple.pkg.CLTools_Executables

HOME Assistant: https://github.com/renemarc/home-assistant-config
UPGRADE automenu: https://github.com/gethomepage/homepage
COPS pour calibre: https://github.com/seblucas/cops ¿ last update 2019

chezmoi init --verbose https://github.com/bhdicaire/dotFiles
OU
chezmoi init --apply --verbose https://github.com/bhdicaire/dotFiles -v

https://support.apple.com/en-ca/102664#:~:text=From%20the%20Apple%20menu%20,Erase%20All%20Content%20and%20Settings.

Unlink your Apps

There are certain apps that will need to be manually unlinked from your Mac before you say goodbye to it. Some third-party apps require licenses that only work on a limited number of computers, so think about any licenses you may have purchased.

itunes 12 2 iconSimilarly, you should de-authorize your iTunes account on the Mac, as this removes its access to content that you bought from the iTunes Store, iBooks Store, or App Store, including things like music, movies, TV shows, apps, and books.

Sign Out of iCloud

It's also important to disable Find My Mac and sign out of ‌iCloud‌ in macOS. That way you'll know for sure there isn't anything lingering on your Mac that links your Apple ID to this machine. The following steps show you how.

What is a clean install?

A clean install of a new version of macOS is where you erase your boot disk completely and then install the new version on the erased disk. This is the safest method to install a new OS because there is no possibility of file conflicts or clutter causing problems. A clean install can also be a good last resort for fixing problems on your Mac. However, a clean install is also the least convenient and most time-consuming method, so you may not want to do it every time you update macOS.

deux filesystem:
* OS
* Data

It's not if but when that something will break ...

You'll need a copy of your current configuration and data sooner than later


https://pawelgrzybek.com/change-macos-user-preferences-via-command-line/
On macOS, for a non-sanboxed app you will find the plist at the same path and for an app that is sandboxed you will find the plist at ~/Library/Containers/MyApp/Data/Library/Preferences/com.mycompany.MyApp.plist.
UserDefaults.standard

Mac Structure

### Users
/Users/userName

/etc/passwd NOT for Users and Groups
/etc/shells

Shells

Ansible modules: dd

### Apps

CLI
Scripts
Notarized Binary --> Downloaded, Brew and App Store
Funky Binary
Licences
Safari Extensions

### Settings

Configuration accessible via GUI such as Settings and app related

defaults write xyz

/PlistBuddy


   - name: user's preferences sudo items
     command: "{{ item }}"
     with_items:
      - "{{ spotlightSudo }}"
      - "{{ timeMachineSudo }}"
      - "{{ userPreferencesSudo }}"

# M-CLI Utility --> https://github.com/rgcr/m-cli
# dockComponents

   - name: Dock items
     command: /usr/local/bin/dockutil {{ item }}
     with_items:
      - "{{ dockComponents }}"
     tags: ['preferences']

 - name: Insert items that will open autonaticaly at login
   shell: ~/bin/loginitems.sh -a {{ item }}
   with_items:
     - "{{ loginComponents }}"

#   - name: spotlight preferences
##     command: "{{ spotlightIndex }} enabled=1 name=APPLICATIONS enabled=1 name=DIRECTORIES enabled=1 name=PDF enabled=1 name=IMAGES enabled=1 #name=PRESENTATIONS  enabled=1 name=SPREADSHEETS enabled=1 name=DOCUMENTS {{ spotlightIndexDisabled }}"
#     tags: ['configure', 'now']

   - name: preferences are cached thus some processes needs to be killed
     command: killall {{ item }}
     with_items:
      - "SystemUIServer"
      - "PowerChime"
      - "cfprefsd"
      - "Finder"
      - "Dock"
     tags: ['preferences']


INstall

Your Mac accumulates clutter every time you use it. Temporary files that were never deleted, cache files, language files for languages you don’t use — they all take up space on your boot disk. And if you back up without clearing the clutter, you’ll back that up, too. That means backup and restoring take longer, and you end up with less free space than you could have. You could even argue that restoring from a backup with junk files on it defeats the object of a clean install.
https://macpaw.com/how-to/clean-install-macos-sonoma


1. Bootstrap ansible and stuff
https://thebroken.link/managing-dotfiles-with-ansible/


dotFiles catageory dans Github

https://github.com/holman/dotfiles

Add RSS

https://ben.balter.com//
https://github.com/benbalter/dotfiles/blob/main/config.yml
https://github.com/geerlingguy/dotfiles/blob/master/.osx


https://phelipetls.github.io/posts/favorite-custom-git-commands/

https://phelipetls.github.io/posts/demystifying-git-rebase/

I am Benjamin Mezger, but everyone started calling me Ben at some point in life.

SF SYmboil applicatiojn

-----
çKeyboard customization

On macOS, we use Karabiner-Elements, and on Linux, we use Interception Tools and a few other pieces to make the following changes:

Make Caps Lock serve as Backspace (when tapped) and Left Control (when chorded with another key). When held down alone, Caps Lock fires repeated Backspace events.
Make Return serve as Return (when tapped) and Right Control (when chorded with another key). When held down alone, Return fires repeated Return events.
Toggle Caps Lock on by tapping both Shift keys simultaneously.
Makes the function keys on my external Realforce keyboard behave like the "media" keys on Apple's keyboards.
And these only on macOS:

Swap Option and Command keys on my external Realforce keyboard.
Make the "application" key (extra modifier key on right-hand side) behave as "fn" on Realforce keyboard.
Map Control-I to F6 (only in the terminal) so that it can be mapped independently from Tab in Vim2.
Make "pause" (at far-right of function key row) behave as "power" (effectively, sleep) on Realforce keyboard.
Adds a "SpaceFN" layer that can be activated by holding down Space while hitting other keys; I use this to make the cursor keys available on or near the home row in any app.

Adobe Source Code Pro or any other fixed-width font that includes the Powerline glyphs. http://powerline.readthedocs.io/en/master/installation.html#fonts-installation


defaults

defaults read-type com.apple.finder AppleShowAllFiles


defaults help
List all domains: defaults domains
List all entries containing word:  defaults find ${word}
Show the type for the given domain, key: defaults read-type ${domain} ${key}
Rename old_key to new_key: defaults rename ${domain} ${old_key} ${new_key}

https://macos-defaults.com/

