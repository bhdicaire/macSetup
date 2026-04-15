# Manual Tasks

## Complete setup sequence

This is the authoritative order of operations from bootstrap to working machine.
Each step depends on the previous one.

```
bootstrap.sh          → installs tools, sets zsh as login shell
↓
NEW TERMINAL WINDOW   ← required: shell change only takes effect in new session
↓
op signin             → authenticates 1Password CLI
↓
age key + chezmoi     → pulls encryption key, applies dotfiles
↓
NEW TERMINAL WINDOW   ← recommended: load full zsh config from dotfiles
↓
make build            → full Ansible provisioning
↓
LOGOUT / LOGIN        ← required: Dock, Finder, LaunchAgents take effect
↓
make setapp           → guided SetApp install (20 apps)
↓
REBOOT                ← required for Little Snitch + macFUSE kernel extensions
↓
Manual tasks below
```

### Why the new terminal windows

`chsh` updates the login shell in Open Directory but cannot affect the current
terminal session — that process is already running under a different shell. A new
terminal window starts a fresh login session that reads the updated shell from
the system, loads `/opt/homebrew/bin/zsh`, and sources `.zprofile` so Homebrew
is in `PATH`.

chezmoi templates reference `{{ .chezmoi.os }}`, `HOMEBREW_PREFIX`, and other
values that are only set correctly inside a proper Homebrew zsh login session.
Running `chezmoi apply` from the bootstrap bash session would work for most
files, but template rendering that shells out to Homebrew tools would fail.

### Why logout/login (not reboot) after `make build`

Most macOS `defaults write` changes are read by processes at launch. The Dock
and Finder need to be restarted (the playbook does this via handlers), but the
login session itself needs to cycle for:

- LaunchAgents (loaded by `launchd` at login)
- Login items (activated by the system on session start)
- Environment variables written to shell config

A full reboot is NOT needed for any of this — logout and back in is sufficient.

### When a full reboot IS required

Little Snitch and macFUSE install kernel extensions (system extensions on
Tahoe). macOS requires a reboot to activate them and will show a prompt in
System Settings → Privacy & Security to approve the extension first. Approve
the extension, then reboot. You can batch both approvals into a single reboot.

Karabiner-Elements does NOT require a reboot — it only needs Input Monitoring
permission granted in Privacy & Security.

FileVault requires a reboot to begin encryption (enable it, reboot, then it
encrypts in the background while you work).

---

Post-playbook steps in the order you should tackle them.

## Immediately after first boot

- [ ] Sign in with Apple ID → System Settings → Apple Account
- [ ] Enable FileVault (System Settings → Privacy & Security → FileVault)
- [ ] Sign in to iCloud if needed (Drive is off by default in this setup)

## Licences to transfer (deallocate on Hal9000 first)

| App | Where | Notes |
|-----|-------|-------|
| Parallels Desktop | parallels.com account | Deactivate on Hal9000 before wiping |
| Little Snitch | at.obdev.at account | Transfer or re-enter licence |
| Keyboard Maestro | stairways.com account | |
| Fantastical | flexibits.com account | |
| OmniGraffle | omnigroup.com account | |
| MindManager | mindjet.com account | |
| Kaleidoscope | kaleidoscope.app account | |
| Banktivity | agsilver.net account | |
| RightFont | rightfontapp.com account | |
| Roon | roonlabs.com account | |

## SetApp — run the guided installer

```bash
cd ~/Developer/macSetup
make setapp
```

This opens each app's page in SetApp one at a time. Press Enter to advance.

Apps installed via SetApp on Dogbert:
- [ ] Bartender
- [ ] Bear
- [ ] Bike
- [ ] BusyContacts
- [ ] CleanMyMac X
- [ ] CleanShot X
- [ ] ForkLift
- [ ] Gemini
- [ ] Hookmark
- [ ] HoudahSpot
- [ ] iStat Menus
- [ ] Lungo
- [ ] Marked
- [ ] Merlin Project Express
- [ ] Nitro PDF Pro
- [ ] OpenIN
- [ ] PDF Squeezer
- [ ] Permute
- [ ] PullTube
- [ ] Soulver

## Microsoft Office + Apple Mail

- [ ] Open any Office app → sign in to Microsoft 365 account
- [ ] Open Apple Mail → Add account → Microsoft Exchange (Office 365)
- [ ] Open Mimestream → sign in to Gmail account
- [ ] Microsoft AutoUpdate → check for updates
- [ ] OneDrive (MAS) → sign in, configure sync folders

## Karabiner-Elements — verify device IDs

The built-in keyboard product ID may differ on Dogbert (M3 Max) vs Hal9000.

1. Open **Karabiner-Elements → EventViewer → Devices**
2. Press any key on the MacBook built-in keyboard
3. Note the `vendor_id` and `product_id` shown
4. Compare to `~/.config/karabiner/karabiner.json` (currently `vendor_id: 3141, product_id: 30354`)
5. If different, update and commit:
   ```bash
   bbedit ~/.config/karabiner/karabiner.json
   chezmoi add ~/.config/karabiner/karabiner.json
   cd ~/.local/share/chezmoi && git add -A && git commit -m "fix(karabiner): update built-in keyboard product_id for Dogbert"
   ```

See `doc/karabiner.md` for the full remapping reference.

## 1Password

- [ ] Verify SSH agent integration: `ssh-add -l` (should show keys from 1Password)
- [ ] Verify `op` CLI: `op vault list`
- [ ] Install browser extensions for Firefox, Chrome, Safari

## GPG

- [ ] Import private key from 1Password:
  ```bash
  op document get "GPG Private Key" | gpg --import
  ```
- [ ] Set ultimate trust:
  ```bash
  gpg --edit-key <key-id>
  > trust → 5 → quit
  ```
- [ ] Verify git signing: `echo test | gpg --clearsign`

## SSH

Private keys are in 1Password → SSH agent handles them automatically via:
```
IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

- [ ] Test GitHub: `ssh -T git@github.com`
- [ ] Check `~/.ssh/config.local` is in place (sensitive hosts — copy from capture archive)

## Elgato hardware

- [ ] Open Elgato Stream Deck → restore profile from:
  `~/Desktop/mac-capture-*/prefs/` (was not captured — set up manually)
- [ ] Elgato Camera Hub, Wave Link — re-configure audio routing

## Fujitsu ScanSnap

- [ ] Open ScanSnap Home → re-configure scan profiles
  (profile data not easily portable — set up from scratch)

## Keyboard Maestro

Preferences backed up at: `~/Desktop/mac-capture-20260410_135924/prefs/Keyboard_Maestro/`

- [ ] Open Keyboard Maestro → File → Start Syncing Macros → choose sync file
  (if you used iCloud/Dropbox sync on Hal9000)
  OR
- [ ] File → Import Macros → select backup plist

Set up Hyper key macros — see `doc/karabiner.md#keyboard-maestro-integration` for the reference table.

## DEVONthink

- [ ] Open DEVONthink → Preferences → Sync → configure CloudKit or Bonjour sync
  Backup location: `~/Desktop/mac-capture-20260410_135924/prefs/DEVONthink/`

## Time Machine

- [ ] Connect Time Machine drive
- [ ] System Settings → General → Time Machine → Add Backup Disk

## Final verification

```bash
cd ~/Developer/macSetup
make info          # machine state
chezmoi status     # dotfiles applied
brew doctor        # Homebrew health
ssh -T git@github.com     # SSH via 1Password agent
gpg --list-secret-keys    # GPG keys present
```
