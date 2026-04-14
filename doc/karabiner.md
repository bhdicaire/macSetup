# Karabiner-Elements Configuration

## What is configured

### CapsLock → Hyper Key + Escape

The most important remapping. CapsLock becomes two things:

| Action | Result |
|--------|--------|
| **Hold** CapsLock | Sends `⌘ + ⌃ + ⌥ + ⇧` simultaneously (the "Hyper" key) |
| **Tap** CapsLock alone | Sends `Escape` |

**Why:** CapsLock is the most valuable unused key on a keyboard. As a Hyper key it gives Keyboard Maestro a dedicated modifier namespace (`Hyper+T` = open Things, `Hyper+B` = Bear, etc.) that never conflicts with any app shortcut. As Escape it replaces the awkward Fn+Escape on the MacBook Pro Touch Bar layout, which is essential for Vim and terminal use.

### External Logitech keyboards — ⌘ ↔ ⌥ swap

Two Logitech keyboards (vendor `1133`, products `50504` and `50484`) have their left Command and left Option keys swapped. On a Windows-layout keyboard the physical positions are reversed from Apple's layout — this swap restores muscle memory.

The flag `disable_built_in_keyboard_if_exists: true` means when the external keyboard is connected, the MacBook's built-in keyboard is suspended. This prevents double-input when the laptop is docked.

### Fn keys

Mapped to standard macOS multimedia functions. On an external keyboard without media keys, F1–F12 act as brightness, Mission Control, Launchpad, keyboard backlight, media playback, mute, and volume.

## Device IDs

Karabiner identifies keyboards by `vendor_id` and `product_id`. These are stable per hardware model.

| vendor_id | product_id | Device | Role |
|-----------|------------|--------|------|
| 1452 | 34304 | Apple Magic Keyboard (ISO) | treat as built-in |
| 3141 | 30354 | MacBook Pro built-in (Hal9000) | treat as built-in |
| 1133 | 50504 | Logitech (primary external) | Cmd↔Option swap, disable built-in |
| 1133 | 50484 | Logitech (secondary external) | Cmd↔Option swap |

**On Dogbert:** The MacBook Pro built-in keyboard product ID (`30354`) may differ. Verify after Karabiner installs:

1. Open **Karabiner-Elements → EventViewer → Devices**
2. Press any key on the built-in keyboard
3. Note the `vendor_id` and `product_id`
4. Update `karabiner.json` if they differ from the values above
5. Run `chezmoi add ~/.config/karabiner/karabiner.json` to commit the change

## Adding new rules

The preferred way is via **Karabiner-Elements GUI → Complex Modifications → Add rule** (imports from karabiner-elements.plist.org), then export the resulting `karabiner.json` and update the repo:

```bash
chezmoi add ~/.config/karabiner/karabiner.json
chezmoi cd
git add dot_config/karabiner/karabiner.json
git commit -m "feat(karabiner): add <description>"
```

Alternatively update `dot_config/karabiner/karabiner.json` directly in the repo and apply with:

```bash
chezmoi apply ~/.config/karabiner/karabiner.json
```

## Keyboard Maestro integration (Hyper key shortcuts)

The Hyper key (`⌘⌃⌥⇧`) is the trigger namespace for Keyboard Maestro macros. Document your macros here as you build them:

| Shortcut | Action |
|----------|--------|
| `Hyper + T` | Open / focus Things 3 |
| `Hyper + B` | Open / focus Bear |
| `Hyper + G` | Open / focus GoodLinks |
| `Hyper + D` | Open / focus DEVONthink |
| `Hyper + E` | Open / focus BBEdit |
| `Hyper + Space` | CleanShot X screenshot |
| `Hyper + F` | Open / focus Fantastical |
| *(add your own)* | |
