# Private Storage Architecture

## The five-tier model

```
Tier 1 · 1Password          Secrets, keys, credentials
Tier 2 · GitHub (public)    Playbook + dotfiles (no secrets)
Tier 3 · GitHub (encrypted) Private dotfiles, encrypted with age
Tier 4 · NAS public share   Licensed fonts, non-sensitive app assets
Tier 5 · NAS private share  Captures, app prefs, KM macros
```

No single tier has everything. A compromised GitHub account exposes no
credentials and no private hostnames. A compromised NAS exposes no
credentials and no secrets. 1Password is the single root of trust.

---

## Tier 1 — 1Password

What lives here and why:

| Item name | Type | Used by |
|-----------|------|---------|
| `macOS sudo` | Login (password field) | Ansible become_pass |
| `NAS` | Login (password field) | nas-setup.sh, roles/nas |
| `chezmoi age key` | Document (.txt) | age-setup.sh, roles/private-dotfiles |
| `GitHub` (email field) | Login | chezmoi.toml template |
| SSH private keys | SSH Key items | 1Password SSH agent (no files on disk) |
| GPG private key | Document | Manual import on new machine |
| AWS credentials | Login | op run -- for CLI tools |

Nothing in the Ansible playbook or chezmoi templates reads from 1Password
except via `op inject` or the `community.general.onepassword` lookup.
Credentials are never written to disk except for:
- `group_vars/secrets.yml` — generated at playbook start, deleted at end
- `~/.config/chezmoi/key.txt` — the age private key, mode 0600

---

## Tier 2 — GitHub public repos

`bhdicaire/macSetup` and `bhdicaire/dotFiles` are fully public.
Safe to be public because:

- All secrets are 1Password references (`op://vault/item/field`)
- All private hostnames are in encrypted Tier 3 files
- The Ansible inventory contains only `localhost`
- `group_vars/secrets.yml` is gitignored and ephemeral
- Font files are gitignored (`roles/fonts/files/fonts/private/`)

---

## Tier 3 — age-encrypted files in dotFiles

Files committed to `bhdicaire/dotFiles` that are encrypted with age.
They look like random bytes in git. On any machine with the age private
key they decrypt transparently during `chezmoi apply`.

### Which files to encrypt

| File | Reason |
|------|--------|
| `~/.ssh/config.local` | Private hostnames, client IPs, jumpbox addresses |
| `~/.aws/credentials` | AWS access keys (if not using `op run --`) |
| `~/.config/gh/hosts.yml` | GitHub CLI OAuth tokens |
| Any `~/.config/*/tokens` | App tokens with no 1Password integration |

### How to add an encrypted file

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

### How decryption works on a new machine

1. `roles/private-dotfiles` pulls the age key from 1Password
2. Saves it to `~/.config/chezmoi/key.txt` (mode 0600)
3. `chezmoi apply` sees `[age]` config in `chezmoi.toml`
4. Decrypts all `.age` files transparently
5. Places decrypted files at their target paths

No manual step required.

### Rotating the age key

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

---

## Tier 4 — NAS public share

SMB share accessible to all devices on your LAN. Anonymous read (guest
access). Not encrypted — threat model: someone on your local network
getting a font file is acceptable.

### Directory structure

```
public/
├── fonts/
│   ├── operator-mono-nerd-font/    # 4 Nerd Font patched .otf files
│   ├── averta/                     # Kostic Type Foundry (licensed)
│   ├── circular-std/               # Lineto (licensed)
│   └── other/                      # Trade Gothic, Documan, Stellage, etc.
```

### Populating (on Hal9000 before wiping)

```bash
make nas-setup
```

### Verifying layout

```bash
make nas-verify
```

---

## Tier 5 — NAS private share

SMB share requiring authentication. Credentials in 1Password item `NAS`.

### Directory structure

```
private/
├── keyboard-maestro/
│   └── Keyboard Maestro Macros.kmsync
├── karabiner/
│   └── (backup configs)
├── prefs/
│   ├── DEVONthink/
│   ├── Fantastical/
│   ├── ChronoSync/
│   ├── Hazel/
│   └── Keyboard_Maestro/
└── captures/
    └── mac-capture-20260410_135924.tar.gz
```

### Why not encrypted

The NAS private share uses authenticated SMB — only your account can
read it. The files it contains (app preferences, macro libraries) are
sensitive to lose but not secrets in a cryptographic sense.
They don't contain credentials.

If your threat model requires it (e.g. the NAS drive is physically
accessible), add age encryption for the captures:

```bash
# Encrypt a capture archive before copying to NAS
age -r <your-public-key> \
  -o mac-capture-20260410_135924.tar.gz.age \
  mac-capture-20260410_135924.tar.gz
```

---

## Order of operations — Hal9000 → Dogbert

```
On Hal9000 (before wiping):
  1. make capture              # snapshot everything
  2. make age-setup            # generate age key → 1Password
  3. chezmoi add --encrypt     # encrypt private dotfiles
  4. git push                  # push encrypted dotFiles
  5. make nas-setup            # fonts + prefs → NAS

On Dogbert (fresh Tahoe install):
  1. scripts/bootstrap.sh      # Xcode CLT, Homebrew, op
  2. eval $(op signin)         # authenticate 1Password CLI
  3. make build                # full playbook
     ├── bootstrap             # tools
     ├── packages              # brew, cask, mas
     ├── fonts                 # bundled fonts
     ├── nas                   # pull from NAS
     ├── macos                 # defaults, Dock
     ├── dotfiles              # chezmoi public
     ├── private-dotfiles      # age key from 1P → decrypt Tier 3
     └── services              # login items, Karabiner, SetApp
  4. make setapp               # guided SetApp install
  5. doc/manual-tasks.md       # remaining manual steps
```
