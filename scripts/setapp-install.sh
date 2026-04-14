#!/usr/bin/env zsh
# ============================================================
# setapp-install.sh — guided SetApp application installer
#
# SetApp has no public CLI or install API. This script uses
# the setapp:// URL scheme to open each app's page in SetApp
# so you can click Install with a single keypress.
#
# Prerequisites:
#   - SetApp cask installed (brew install --cask setapp)
#   - Signed in to your SetApp account
#   - SetApp subscription active
#
# Usage:
#   chmod +x scripts/setapp-install.sh
#   ./scripts/setapp-install.sh
#
# What it does:
#   Opens each app in SetApp one at a time.
#   You press Enter to advance to the next app, giving you
#   time to click "Install" in the SetApp window.
#   Already-installed apps will simply show their page — safe
#   to run again after a wipe.
# ============================================================

set -euo pipefail

BOLD='\033[1m'; GREEN='\033[32m'; YELLOW='\033[33m'; BLUE='\033[34m'; RESET='\033[0m'

# ── Verify SetApp is running ──────────────────────────────────
if ! pgrep -x "Setapp" &>/dev/null; then
  echo "${YELLOW}SetApp is not running. Launching...${RESET}"
  open -a "Setapp"
  sleep 3
fi

# ── App list with SetApp URL slugs ────────────────────────────
# Format: "Display Name|setapp-slug"
# Slugs found at: https://setapp.com/apps/<slug>
APPS=(
  "Bartender|bartender"
  "Bear|bear-markdown-notes"
  "Bike|bike-outliner"
  "BusyContacts|busycontacts"
  "CleanMyMac X|cleanmymac"
  "CleanShot X|cleanshot"
  "ForkLift|forklift"
  "Gemini|gemini"
  "Hookmark|hookmark"
  "HoudahSpot|houdahspot"
  "iStat Menus|istat-menus"
  "Lungo|lungo"
  "Marked|marked"
  "Merlin Project Express|merlin-project-express"
  "PDF Squeezer|pdf-squeezer"
  "Permute|permute"
  "PullTube|pulltube"
  "Soulver|soulver"
)

TOTAL=${#APPS[@]}
CURRENT=0

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║          SetApp Guided Installation                 ║"
echo "║                                                      ║"
echo "║  SetApp will open to each app's page.              ║"
echo "║  Click Install (or skip if already installed).     ║"
echo "║  Press Enter here to advance to the next app.      ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "  ${BOLD}${TOTAL} apps to install${RESET}"
echo ""

for entry in "${APPS[@]}"; do
  NAME="${entry%%|*}"
  SLUG="${entry##*|}"
  (( CURRENT++ ))

  echo "${BLUE}[${CURRENT}/${TOTAL}]${RESET} ${BOLD}${NAME}${RESET}"

  # Check if already installed
  if [[ -d "/Applications/${NAME}.app" ]]; then
    echo "  ${GREEN}✓ Already installed — skipping${RESET}"
    echo ""
    continue
  fi

  # Open SetApp to the app's page
  open "setapp://show/${SLUG}" 2>/dev/null || \
    open "https://setapp.com/apps/${SLUG}"

  echo "  → SetApp opened to ${NAME}. Click Install, then press Enter..."
  read -r _
  echo ""
done

echo "╔══════════════════════════════════════════════════════╗"
echo "║          SetApp installation complete  🎉           ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "Apps installed via SetApp:"
for entry in "${APPS[@]}"; do
  NAME="${entry%%|*}"
  if [[ -d "/Applications/${NAME}.app" ]]; then
    echo "  ${GREEN}✓${RESET} ${NAME}"
  else
    echo "  ${YELLOW}?${RESET} ${NAME} — verify manually"
  fi
done
echo ""
