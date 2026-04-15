#!/usr/bin/env bash
# ============================================================
# bootstrap.sh — fresh macOS Tahoe pre-flight
#
# Run this ONCE on a new machine before the Ansible playbook.
# It installs the minimum tools needed to run macSetup.
#
# Prerequisites:
#   - macOS Tahoe (26+) on Apple Silicon
#   - Internet connection
#   - Apple ID signed in (System Settings)
#   - 1Password app installed and unlocked
#
# What it installs:
#   - Xcode Command Line Tools
#   - Rosetta 2
#   - Homebrew
#   - Core bootstrap formulae: git, ansible, chezmoi, 1password-cli,
#     mas, dockutil, duti, m-cli, starship, eza
#
# Usage:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/bhdicaire/macSetup/main/scripts/bootstrap.sh)"
# or locally:
#   chmod +x scripts/bootstrap.sh && ./scripts/bootstrap.sh
# ============================================================

set -euo pipefail

BREW="/opt/homebrew/bin/brew"

# ── Colours ───────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; RESET='\033[0m'

step()    { echo ""; echo "${BOLD}${BLUE}▶ $*${RESET}"; }
ok()      { echo "${GREEN}  ✓ $*${RESET}"; }
warn()    { echo "${YELLOW}  ⚠ $*${RESET}"; }
die()     { echo "${RED}  ✗ $*${RESET}"; exit 1; }

# ── Preflight checks ──────────────────────────────────────────
step "Pre-flight checks"

# Apple Silicon only
if [[ "$(uname -m)" != "arm64" ]]; then
  die "This playbook targets Apple Silicon (arm64). Detected: $(uname -m)"
fi
ok "Apple Silicon detected"

# macOS version
OS_VER=$(sw_vers -productVersion)
OS_MAJOR=$(echo "$OS_VER" | cut -d. -f1)
if (( OS_MAJOR < 26 )); then
  warn "macOS Tahoe (26+) expected. Detected: $OS_VER"
  warn "Continuing anyway — some defaults keys may differ on older versions."
else
  ok "macOS ${OS_VER} (Tahoe)"
fi

# Internet
if ! curl -s --max-time 5 https://api.github.com > /dev/null 2>&1; then
  die "No internet connection. Connect and retry."
fi
ok "Internet connection"

# ── Xcode Command Line Tools ──────────────────────────────────
step "Xcode Command Line Tools"
if xcode-select --print-path &>/dev/null 2>&1; then
  ok "Already installed at $(xcode-select --print-path)"
else
  echo "  Installing — a GUI prompt will appear. Click 'Install'."
  xcode-select --install 2>/dev/null || true
  # Wait for installation
  until xcode-select --print-path &>/dev/null 2>&1; do
    sleep 5
    echo "  Waiting for Xcode CLT..."
  done
  ok "Xcode Command Line Tools installed"
fi

# Accept licence
sudo xcodebuild -license accept 2>/dev/null || true

# ── Rosetta 2 ─────────────────────────────────────────────────
step "Rosetta 2"
if /usr/bin/pgrep oahd &>/dev/null; then
  ok "Rosetta 2 already running"
else
  echo "  Installing Rosetta 2..."
  sudo softwareupdate --install-rosetta --agree-to-license
  ok "Rosetta 2 installed"
fi

# ── Homebrew ──────────────────────────────────────────────────
step "Homebrew"
if [[ -x "$BREW" ]]; then
  ok "Homebrew already at $BREW"
  "$BREW" update --quiet
else
  echo "  Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ok "Homebrew installed"
fi

# Add Homebrew to PATH for this session
eval "$("$BREW" shellenv)"

# Disable analytics
"$BREW" analytics off
ok "Homebrew analytics disabled"

# ── Bootstrap formulae ────────────────────────────────────────
step "Bootstrap formulae"

FORMULAE=(
  git           # version control
  ansible       # the provisioner
  chezmoi       # dotfile manager
  1password     # password manager GUI
  1password-cli # password manager CLI
  mas           # Mac App Store CLI
  dockutil      # Dock management
  duti          # file type associations
  m-cli         # macOS CLI utility
  starship      # shell prompt
  eza           # modern ls
  age           # secure file encryption CLI
  vim           # Vi 'workalike', useful for debugging
)

for formula in "${FORMULAE[@]}"; do
  if "$BREW" list --formula "$formula" &>/dev/null; then
    ok "$formula (already installed)"
  else
    echo "  Installing $formula..."
    "$BREW" install --quiet "$formula"
    ok "$formula"
  fi
done

# Ansible collections
step "Ansible Galaxy collections"
ansible-galaxy collection install community.general --upgrade --quiet
ok "community.general installed"

# ── 1Password CLI authentication ──────────────────────────────
step "1Password CLI"
echo "  Checking op authentication..."
if op account list --format=json &>/dev/null; then
  ok "1Password CLI authenticated ($(op account list --format=json | python3 -c 'import json,sys; accts=json.load(sys.stdin); print(accts[0]["email"] if accts else "unknown")' 2>/dev/null))"
else
  warn "1Password CLI not authenticated."
  echo ""
  echo "  Run: op signin"
  echo "  or:  eval \$(op signin)"
  echo ""
  read -r -p "  Press Enter to open 1Password for authentication, or Ctrl-C to abort..." _
  open -a "1Password"
  echo "  Once 1Password is unlocked and CLI is granted permission, run:"
  echo "    eval \$(op signin)"
  echo "  Then re-run this script."
  exit 1
fi

# ── Clone macSetup ─────────────────────────────────────────────
step "macSetup repository"
MACSETUP_DIR="${HOME}/code/macSetup"

if [[ -d "$MACSETUP_DIR/.git" ]]; then
  ok "Already cloned at $MACSETUP_DIR"
  git -C "$MACSETUP_DIR" pull --quiet
else
  echo "  Cloning macSetup..."
  mkdir -p "${HOME}/code"
  git clone https://github.com/bhdicaire/macSetup.git "$MACSETUP_DIR"
  ok "Cloned to $MACSETUP_DIR"
fi

# ── Computer name ─────────────────────────────────────────────
step "Computer identity"
CURRENT_NAME=$(scutil --get ComputerName 2>/dev/null || echo "")
if [[ -z "$CURRENT_NAME" || "$CURRENT_NAME" == "My Mac" ]]; then
  echo ""
  read -r -p "  Enter computer name (e.g. Minuit): " COMP_NAME
  if [[ -n "$COMP_NAME" ]]; then
    sudo scutil --set ComputerName  "$COMP_NAME"
    sudo scutil --set LocalHostName "$(echo "$COMP_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
    sudo scutil --set HostName      "$(echo "$COMP_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
    ok "Computer name set to: $COMP_NAME"
  fi
else
  ok "Computer name: $CURRENT_NAME"
fi

# ── Summary ───────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║              Bootstrap Complete  🎉                 ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "  Next steps:"
echo ""
echo "  1. Review and edit configuration:"
echo "       $MACSETUP_DIR/host_vars/localhost/main.yml"
echo "       $MACSETUP_DIR/group_vars/all/packages.yml"
echo ""
echo "  2. Run the playbook:"
echo "       cd $MACSETUP_DIR && make build"
echo ""
echo "  Or run individual sections:"
echo "       make build TAGS=brew"
echo "       make build TAGS=defaults"
echo "       make build TAGS=dotfiles"
echo ""
