# macSetup

[![Lint](https://github.com/bhdicaire/macSetup/actions/workflows/lint.yml/badge.svg)](https://github.com/bhdicaire/macSetup/actions)
[![macOS Tahoe](https://img.shields.io/badge/macOS-Tahoe-000000?logo=apple)](https://www.apple.com/macos/)
[![Ansible](https://img.shields.io/badge/ansible-%3E%3D2.16-EE0000?logo=ansible)](https://www.ansible.com/)
[![chezmoi](https://img.shields.io/badge/managed%20by-chezmoi-00A1E8)](https://chezmoi.io/)
[![1Password](https://img.shields.io/badge/secrets-1Password-0094F5?logo=1password)](https://1password.com/)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

An opinionated Ansible playbook to provision a fresh macOS Tahoe installation on Apple Silicon from scratch — without the cruft of a migration or update.

**Philosophy:** complexity is the enemy of security. Clean slate, automated, reproducible.

## What it does

| Phase | What happens |
|-------|-------------|
| **Bootstrap** | Xcode CLT → Rosetta 2 → Homebrew → core tools → 1Password CLI |
| **Packages** | Homebrew formulae, casks (GUI apps), Mac App Store apps via `mas` |
| **Fonts** | Homebrew cask fonts + private bundled fonts |
| **macOS defaults** | Finder, Dock, UX, security, Safari, Mail, BBEdit, Office, and more |
| **dotFiles** | chezmoi init + apply from [bhdicaire/dotFiles](https://github.com/bhdicaire/dotFiles) with macOS extensions |
| **Services** | Login items, Automator workflows, GPG agent, file-type associations |

## Before you wipe your current Mac

Run the capture script on your **Sonoma machine**:

```bash
./scripts/capture.sh
```

This snapshots your Brew list, MAS apps, key preferences, SSH config (public keys only), GPG public keys, Karabiner config, and shell history into a timestamped archive on your Desktop.

Review `doc/manual-tasks.md` for the checklist of things to handle manually (licence deallocation, private keys into 1Password, etc.).

## Setting up a fresh Tahoe machine

### Step 1 — Boot and sign in

1. Language: **English**
2. Country: **Canada**
3. Accessibility: *not now*
4. Migration Assistant: **skip — this is the point**
5. Sign in with your Apple ID
6. Create your account

### Step 2 — Bootstrap

Open Terminal and run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/bhdicaire/macSetup/main/scripts/bootstrap.sh)"
```

This installs Xcode CLT, Homebrew, Ansible, chezmoi, `mas`, and other prerequisites. It will prompt you to authenticate the 1Password CLI.

### Step 3 — Configure

Edit machine-specific settings:

```bash
cd ~/Developer/macSetup
$EDITOR host_vars/localhost/main.yml   # computer name, Dock layout, directories
$EDITOR group_vars/all/packages.yml    # add/remove software
```

### Step 4 — Run

```bash
make build
```

Grab a coffee. When it finishes, log out and back in for all defaults to take effect.

### Step 5 — Manual tasks

Follow `doc/manual-tasks.md` for the remaining manual steps (SetApp, licences, FileVault, etc.).

## Selective runs with tags

```bash
make build TAGS=brew          # only Homebrew formulae + casks
make build TAGS=mas           # only App Store apps
make build TAGS=defaults      # only macOS system defaults
make build TAGS=dock          # only Dock layout
make build TAGS=dotfiles      # only chezmoi / dotfiles
make build TAGS=security      # only security settings
make build TAGS=fonts         # only font installation
```

## Secrets

No secrets are stored in this repository. All sensitive values are pulled from **1Password** at runtime via the `op` CLI.

```bash
# Inject secrets before running (handled automatically by `make build`)
op inject -i group_vars/secrets.yml.tmpl -o group_vars/secrets.yml
```

See `group_vars/secrets.yml.example` for the shape of the secrets file.

## Repository structure

```
macSetup/
├── macSetup.yml                    # Main playbook
├── ansible.cfg
├── inventory
├── Makefile
├── requirements.yml                # Ansible Galaxy collections
│
├── group_vars/
│   └── all/
│       ├── defaults.yml            # Machine-agnostic defaults
│       ├── packages.yml            # All software: brew, cask, mas
│       └── macos.yml               # All osx_defaults by domain
│
├── host_vars/
│   └── localhost/
│       └── main.yml                # THIS machine: name, Dock, dirs
│
├── roles/
│   ├── bootstrap/                  # Xcode CLT, Rosetta, Homebrew
│   ├── packages/                   # brew, cask, mas installs
│   ├── macos/                      # defaults, Dock, Finder, security
│   ├── dotfiles/                   # chezmoi init + apply
│   ├── fonts/                      # private/bundled fonts
│   └── services/                   # login items, Automator, GPG
│
├── scripts/
│   ├── capture.sh                  # Run on OLD machine before wiping
│   └── bootstrap.sh                # Run on NEW machine before Ansible
│
└── doc/
    ├── manual-tasks.md             # What can't be automated
    └── chezmoi-macos.md            # Extending dotFiles for macOS
```

## dotFiles integration

The chezmoi `dotFiles` role initialises [bhdicaire/dotFiles](https://github.com/bhdicaire/dotFiles) and adds macOS-specific configuration via `{{ if eq .chezmoi.os "darwin" }}` template guards. See [`doc/chezmoi-macos.md`](doc/chezmoi-macos.md) for details on what to add to the dotFiles repo.

## Related

- [bhdicaire/dotFiles](https://github.com/bhdicaire/dotFiles) — chezmoi-managed dotfiles (Linux + macOS)
- [Homebrew](https://brew.sh)
- [chezmoi](https://chezmoi.io)
- [mas-cli](https://github.com/mas-cli/mas)

## Licence

MIT — see [LICENSE](LICENSE).
