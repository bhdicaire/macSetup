#!/usr/bin/env zsh
# ============================================================
# capture.sh — snapshot current Mac before a clean wipe
#
# Run this on your Sonoma machine BEFORE wiping.
# Creates a timestamped archive at ~/Desktop/mac-capture-<date>/
#
# Usage:
#   chmod +x scripts/capture.sh
#   ./scripts/capture.sh
#
# What it captures:
#   ✓ Homebrew formulae + casks (brew bundle dump)
#   ✓ Mac App Store apps (mas list)
#   ✓ All defaults domains (for diffing later)
#   ✓ SSH config and public keys (NOT private keys)
#   ✓ GPG public keys
#   ✓ Application preferences (selected plists)
#   ✓ Shell history (zsh)
#   ✓ crontabs
#   ✓ Little Snitch rules (plist)
#   ✓ Karabiner-Elements config
#   ✓ ~/bin directory
#   ✓ Installed fonts list
#   ✓ LaunchAgents list
#
# What it does NOT capture (managed by 1Password):
#   ✗ Private SSH keys
#   ✗ GPG private keys
#   ✗ Passwords / tokens
#   ✗ .env files
# ============================================================

set -euo pipefail

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DEST="$HOME/Desktop/mac-capture-${TIMESTAMP}"
LOG="${DEST}/capture.log"

# ── Colour helpers ────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

info()    { echo "${BLUE}→${RESET} $*" | tee -a "$LOG" }
success() { echo "${GREEN}✓${RESET} $*" | tee -a "$LOG" }
warn()    { echo "${YELLOW}⚠${RESET} $*" | tee -a "$LOG" }
error()   { echo "${RED}✗${RESET} $*" | tee -a "$LOG" }

# ── Preflight ─────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║         macSetup — Pre-wipe Capture Script          ║"
echo "║    Run on Sonoma before wiping. Output: Desktop     ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

mkdir -p "${DEST}"/{brew,mas,defaults,prefs,shell,ssh,gpg,fonts,bin,launchagents,karabiner}
echo "Capture started at $(date)" > "$LOG"

BREW_BIN=$(command -v brew || echo "/opt/homebrew/bin/brew")
if [[ ! -x "$BREW_BIN" ]]; then
  error "Homebrew not found. Skipping brew sections."
  BREW_BIN=""
fi

# ── Homebrew ──────────────────────────────────────────────────
if [[ -n "$BREW_BIN" ]]; then
  info "Capturing Homebrew state..."

  # Full Brewfile (formulae + casks + taps + MAS)
  "$BREW_BIN" bundle dump --force --file="${DEST}/brew/Brewfile" 2>>"$LOG" && \
    success "Brewfile → ${DEST}/brew/Brewfile" || warn "brew bundle dump failed"

  # Separate lists for easy review
  "$BREW_BIN" list --formula   > "${DEST}/brew/formulae.txt"   2>>"$LOG"
  "$BREW_BIN" list --cask      > "${DEST}/brew/casks.txt"      2>>"$LOG"
  "$BREW_BIN" tap              > "${DEST}/brew/taps.txt"        2>>"$LOG"
  "$BREW_BIN" leaves           > "${DEST}/brew/leaves.txt"      2>>"$LOG"
  "$BREW_BIN" info --json=v2 --installed > "${DEST}/brew/installed.json" 2>>"$LOG"
  success "Homebrew lists captured"
fi

# ── Mac App Store ─────────────────────────────────────────────
if command -v mas &>/dev/null; then
  info "Capturing Mac App Store apps..."
  mas list > "${DEST}/mas/installed.txt" 2>>"$LOG" && \
    success "MAS list → ${DEST}/mas/installed.txt" || warn "mas list failed"
else
  warn "mas not installed — skipping App Store capture"
fi

# ── macOS defaults ────────────────────────────────────────────
info "Capturing macOS defaults (this takes a moment)..."

DOMAINS=(
  NSGlobalDomain
  com.apple.ActivityMonitor
  com.apple.dock
  com.apple.finder
  com.apple.Safari
  com.apple.mail
  com.apple.Siri
  com.apple.assistant.backedup
  com.apple.TimeMachine
  com.apple.SoftwareUpdate
  com.apple.commerce
  com.apple.screensaver
  com.apple.screencapture
  com.apple.desktopservices
  com.apple.ImageCapture
  com.apple.CrashReporter
  com.apple.driver.AppleBluetoothMultitouch.trackpad
  com.barebones.bbedit
  com.microsoft.autoupdate2
  com.microsoft.Word
  com.microsoft.Excel
  com.microsoft.Outlook
  com.microsoft.rdc.mac
)

for domain in "${DOMAINS[@]}"; do
  safe="${domain//\//_}"
  defaults export "$domain" "${DEST}/defaults/${safe}.plist" 2>>"$LOG" && \
    defaults export "$domain" - 2>/dev/null | plutil -convert json -o "${DEST}/defaults/${safe}.json" - 2>>"$LOG" || true
done

# Dump everything (for grepping)
defaults domains | tr ',' '\n' | tr -d ' ' > "${DEST}/defaults/all-domains.txt"
success "macOS defaults captured"

# ── SSH ───────────────────────────────────────────────────────
info "Capturing SSH config (public keys only)..."
if [[ -d "$HOME/.ssh" ]]; then
  # Config and public keys only — private keys stay on disk / in 1Password
  cp "$HOME/.ssh/config" "${DEST}/ssh/config" 2>>"$LOG" || warn "No ~/.ssh/config"
  cp "$HOME/.ssh/config.local" "${DEST}/ssh/config.local" 2>>"$LOG" || true
  find "$HOME/.ssh" -name "*.pub" -exec cp {} "${DEST}/ssh/" \; 2>>"$LOG"
  find "$HOME/.ssh" -name "known_hosts" -exec cp {} "${DEST}/ssh/" \; 2>>"$LOG"
  success "SSH config + public keys captured (private keys NOT copied)"
fi

# ── GPG public keys ───────────────────────────────────────────
if command -v gpg &>/dev/null; then
  info "Exporting GPG public keys..."
  gpg --export --armor > "${DEST}/gpg/public-keys.asc" 2>>"$LOG" && \
    success "GPG public keys exported" || warn "GPG export failed"
  gpg --list-keys > "${DEST}/gpg/keys-list.txt" 2>>"$LOG"
  warn "GPG private keys NOT exported — ensure they are in 1Password before wiping"
fi

# ── Application preferences ───────────────────────────────────
info "Capturing application preferences..."

PREFS_MAP=(
  "Little Snitch:at.obdev.LittleSnitchNetworkMonitor.plist"
  "Keyboard Maestro:com.stairways.keyboardmaestro.engine.plist"
  "BBEdit:com.barebones.bbedit.plist"
  "Fantastical:com.flexibits.fantastical2.mac.plist"
  "Things:com.culturedcode.ThingsMac.plist"
  "DEVONthink:com.devon-technologies.think3.plist"
  "1Password:com.1password.1password.plist"
  "Hazel:com.noodlesoft.Hazel.plist"
  "ChronoSync:com.econtechnologies.chronosync.plist"
)

PREFS_DIR="$HOME/Library/Preferences"
for entry in "${PREFS_MAP[@]}"; do
  app_name="${entry%%:*}"
  plist_name="${entry##*:}"
  src="${PREFS_DIR}/${plist_name}"
  if [[ -f "$src" ]]; then
    dest_dir="${DEST}/prefs/${app_name// /_}"
    mkdir -p "$dest_dir"
    cp "$src" "$dest_dir/" 2>>"$LOG"
    # Also export as JSON for readability
    plutil -convert json -o "${dest_dir}/${plist_name%.plist}.json" "$src" 2>>"$LOG" || true
    success "${app_name} prefs captured"
  else
    warn "${app_name} pref file not found: $src"
  fi
done

# Little Snitch rules (separate location on newer versions)
LS_RULES="$HOME/Library/Application Support/Little Snitch"
if [[ -d "$LS_RULES" ]]; then
  mkdir -p "${DEST}/prefs/LittleSnitch"
  cp -r "$LS_RULES" "${DEST}/prefs/LittleSnitch/" 2>>"$LOG" && \
    success "Little Snitch rules captured" || warn "Little Snitch rules copy failed"
fi

# Karabiner-Elements
KE_DIR="$HOME/.config/karabiner"
if [[ -d "$KE_DIR" ]]; then
  cp -r "$KE_DIR" "${DEST}/karabiner/" 2>>"$LOG" && \
    success "Karabiner-Elements config captured"
fi

# ── Shell history ─────────────────────────────────────────────
info "Capturing shell history..."
[[ -f "$HOME/.zsh_history" ]] && cp "$HOME/.zsh_history" "${DEST}/shell/zsh_history" 2>>"$LOG"
[[ -f "$HOME/.bash_history" ]] && cp "$HOME/.bash_history" "${DEST}/shell/bash_history" 2>>"$LOG"
success "Shell history captured"

# ── ~/bin ─────────────────────────────────────────────────────
if [[ -d "$HOME/bin" ]]; then
  info "Capturing ~/bin..."
  cp -r "$HOME/bin" "${DEST}/bin/" 2>>"$LOG" && success "~/bin captured"
fi

# ── Installed fonts ───────────────────────────────────────────
info "Listing installed fonts..."
{
  echo "# System fonts"
  ls /System/Library/Fonts/ 2>/dev/null
  echo ""
  echo "# User fonts"
  ls "$HOME/Library/Fonts/" 2>/dev/null
  echo ""
  echo "# /Library/Fonts"
  ls /Library/Fonts/ 2>/dev/null
} > "${DEST}/fonts/installed-fonts.txt"
# Copy user-installed fonts
if [[ -d "$HOME/Library/Fonts" ]]; then
  cp -r "$HOME/Library/Fonts" "${DEST}/fonts/user-fonts" 2>>"$LOG"
  success "User fonts captured"
fi

# ── LaunchAgents ──────────────────────────────────────────────
info "Listing LaunchAgents..."
ls -la "$HOME/Library/LaunchAgents/" > "${DEST}/launchagents/user-agents.txt" 2>>"$LOG" || true
ls -la /Library/LaunchAgents/ > "${DEST}/launchagents/system-agents.txt" 2>>"$LOG" || true
ls -la /Library/LaunchDaemons/ > "${DEST}/launchagents/system-daemons.txt" 2>>"$LOG" || true
success "LaunchAgents list captured"

# ── System info snapshot ──────────────────────────────────────
info "Capturing system info..."
{
  echo "# Capture Date: $(date)"
  echo "# macOS Version: $(sw_vers -productVersion)"
  echo "# Build: $(sw_vers -buildVersion)"
  echo "# Hardware: $(system_profiler SPHardwareDataType | grep 'Model Name')"
  echo "# CPU: $(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo 'Apple Silicon')"
  echo "# RAM: $(system_profiler SPHardwareDataType | grep 'Memory:')"
  echo "# Hostname: $(scutil --get ComputerName)"
  echo "# LocalHostname: $(scutil --get LocalHostName)"
  echo "# User: $USER"
  echo "# Shell: $SHELL"
  echo "# Homebrew prefix: $(brew --prefix 2>/dev/null || echo 'n/a')"
} > "${DEST}/system-info.txt"

# ── chezmoi state ─────────────────────────────────────────────
if command -v chezmoi &>/dev/null; then
  info "Capturing chezmoi state..."
  chezmoi status > "${DEST}/chezmoi-status.txt" 2>>"$LOG" || true
  chezmoi git -- log --oneline -20 > "${DEST}/chezmoi-git-log.txt" 2>>"$LOG" || true
  success "chezmoi state captured"
fi

# ── Summary ───────────────────────────────────────────────────
ARCHIVE="${HOME}/Desktop/mac-capture-${TIMESTAMP}.tar.gz"
info "Creating compressed archive..."
tar -czf "$ARCHIVE" -C "${HOME}/Desktop" "mac-capture-${TIMESTAMP}" 2>>"$LOG" && \
  success "Archive created: $ARCHIVE"

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║                  Capture Complete                   ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "📦 Archive: $ARCHIVE"
echo "📁 Folder:  $DEST"
echo ""
echo "${YELLOW}Before wiping, ensure:${RESET}"
echo "  ☐ Private SSH keys are in 1Password"
echo "  ☐ GPG private keys are in 1Password"
echo "  ☐ Software licences are noted (see doc/manual-tasks.md)"
echo "  ☐ SetApp is signed in and apps are listed"
echo "  ☐ Parallels is deactivated (check licence server)"
echo "  ☐ Little Snitch licence is noted"
echo "  ☐ Keyboard Maestro licence is noted"
echo "  ☐ Time Machine backup is current"
echo "  ☐ SuperDuper clone is current"
echo ""
