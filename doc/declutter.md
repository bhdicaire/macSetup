# user's home directory conventions

Using directories defined by well-known conventions keeps the `~` folder clean and makes migrating between machines and operating systems much simpler.

I use several _package managers_ to automate the installation into these specific paths to simplify system maintenance. 

On a macOS system, managing software efficiently involves a combination of general-purpose and language-specific package managers:

1.  **Homebrew**: Often called the missing package manager for macOS, it is the industry standard for installing command-line tools and desktop applications 
2.  **Mac App Store**: The official Apple channel for consumer-facing apps, ensuring  seamless updates through your Apple ID
3.  **Language-Specific Managers**  handle dependencies for particular programming ecosystem that guarantees that software is added, updated, and removed cleanly
    * **Node.js**: Use **npm**, **Yarn**, or **pnpm** to manage JavaScript libraries 
    * **Python**: Primarily uses **pip** for packages, often managed within virtual environments.
    * **Go**: Uses the built-in **Go modules** (`go get`) system.

## What to put where

> The rationale for using .config and .local is to adhere to the XDG Base Directory Specification, a standard originating from Unix-desktop environments (like GNOME) to declutter the user's home directory

1. **`/Applications`** system-wide directory for applications available to all users downloaded via the Mac App Store or manually by an admin user
2. **`~/Application`**  Located in the user’s home folder, this directory is for apps installed only for a specific user. It does not require administrative privileges for installation.
4. **`/opt/homebrew`**: Use this for CLI tools and GUI apps installed by [Homebrew](https://Brew.sh) on Apple Silicon. It was chosen to prevent conflicts with Intel-based installations (Rosetta 2), which use /usr/local. This separation allows both native ARM and translated x86 binaries managed by [Homebrew](https://Brew.sh) to coexist on the same system.
1. **`~/.config`** Use this for _configuration files_ for tools like git, shell aliases, or text editors. It's also known as _XDG_CONFIG_HOME_[1](https://stackoverflow.com/questions/3373948/equivalents-of-xdg-config-home-and-xdg-data-home-on-mac-os-x).
2. **`~/.local/share` (XDG_DATA_HOME):** Use this for large assets or supporting files that your software needs to run such as application state, local databases, It's also known as _XDG_DATA_HOME.
3. **`~/.local/bin`:**  is commonly used to store **user-specific executable binaries** that aren't managed by a system package manager. Symlink your development executables here. This allows you to run your latest builds globally without moving them out of their repository in ~/code. 
7. **`~/code`**  Use this for the git repositories for active development under version control. Place project-specific versions of your tools here such as vanityURLs & macSetup.

## Files Architecture

No single tier has everything. A compromised GitHub account exposes no
credentials and no private hostnames. A compromised NAS exposes no
credentials and no secrets. 1Password is the single root of trust.

### Public GitHub repos

* [dotFiles](https://github.com/bhdicaire/dotFiles) – Opinionated dot files managed with [Chezmoi](https://www.chezmoi.io/)
* [macSetup](https://github.com/bhdicaire/macSetup) – [Ansible](https://Ansible.com) code to build my Mac from scratch 

Safe to be public because:

- All secrets are 1Password references (`op://vault/item/field`)
- All private hostnames are in encrypted Tier 3 files
- The Ansible inventory contains only `localhost`
- `group_vars/secrets.yml` is gitignored and ephemeral
- Font files are gitignored (`roles/fonts/files/fonts/private/`)


### Secrets managed by [1Password](1Password.com)

  * Ansible templated secrets resolved at runtime

    * SSH private keys
    * GPG private key
    * API tokens, passwords
    * age encryption key (for Tier 3)
    * NAS mount credentials (if not anonymous)
  * Chezmoi templated secrets pulled at chezmoi apply time
    * ~/.ssh/config.local (private hostnames, IPs)
    * ~/.aws/credentials 
    * ~/.config/gh/hosts.yml
    * Any dotfile containing a hostname or IP I don't want public 

### Local SMB share (private)
#### Files (no encryption needed)
  * Licensed fonts
  *  Karabiner backups
  *  App preference archives (captured plists)
  *  macSetup capture archives
  *  Keyboard Maestro macro library backup
#### Encrypted Files
  * Client project files
  * Finance / Banktivity data backup
  * Scanned documents (ScanSnap output)
  * Any file that should survive NAS compromise intact
  
  
##### How to add an encrypted file

```bash
# On Hal9000 — encrypt and add to dotFiles
chezmoi add --encrypt ~/.ssh/config.local

# In the dotFiles repo this creates:
# dot_ssh/encrypted_config.local.age

# Commit it
cd ~/.local/share/chezmoi
git add dot_ssh/encrypted_config.local.age
git commit -m "feat(private): add encrypted ssh config.local"
git push
```

##### How decryption works on a new machine

1. `roles/private-dotfiles` pulls the age key from 1Password
2. Saves it to `~/.config/chezmoi/key.txt` (mode 0600)
3. `chezmoi apply` sees `[age]` config in `chezmoi.toml`
4. Decrypts all `.age` files transparently
5. Places decrypted files at their target paths

No manual step required.

##### Rotating the age key

```bash
# Generate new keypair
age-keygen -o ~/.config/chezmoi/key.txt.new

# Re-encrypt all existing age files
chezmoi re-add  # or: chezmoi add --encrypt for each file

# Update chezmoi.toml recipient
# Update 1Password document

# Push new encrypted files, remove old
git add -A && git commit -m "chore(age): rotate encryption key"
```