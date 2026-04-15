#!/usr/bin/env zsh
# ============================================================
# nas-setup.sh — initialise NAS share structure
#
# Run on Hal9000 BEFORE wiping to:
#   1. Mount both NAS shares
#   2. Create the expected directory tree
#   3. Copy licensed fonts from ~/Library/Fonts
#   4. Copy Keyboard Maestro macro library
#   5. Copy app preference backups from capture archive
#
# Run again on Dogbert after setup to verify the layout.
#
# Prerequisites:
#   - NAS reachable on local network
#   - SMB share credentials in 1Password item "NAS"
#   - op authenticated
#
# Usage:
#   chmod +x scripts/nas-setup.sh
#   ./scripts/nas-setup.sh [--verify]
#
#   --verify: check NAS layout without copying anything
# ============================================================

set -euo pipefail

BOLD='\033[1m'; GREEN='\033[32m'; YELLOW='\033[33m'
BLUE='\033[34m'; RED='\033[31m'; RESET='\033[0m'

NAS_HOST="nas.local"
NAS_USER="bhdicaire"
NAS_PUBLIC_SHARE="public"
NAS_PRIVATE_SHARE="private"
MOUNT_ROOT="/Volumes/NAS"
VERIFY_ONLY="${1:-}"

info()    { echo "${BLUE}→${RESET} $*"; }
ok()      { echo "${GREEN}✓${RESET} $*"; }
warn()    { echo "${YELLOW}⚠${RESET}  $*"; }
die()     { echo "${RED}✗${RESET} $*"; exit 1; }

# ── Preflight ─────────────────────────────────────────────────
ping -c 1 -W 2 "$NAS_HOST" &>/dev/null || die "NAS ($NAS_HOST) not reachable"
op account list &>/dev/null || die "1Password CLI not authenticated"

NAS_PASS=$(op item get "NAS" --vault Private --field password 2>/dev/null) || \
  die "Could not retrieve NAS password from 1Password item 'NAS'"

# ── Mount ─────────────────────────────────────────────────────
info "Mounting NAS shares..."
mkdir -p "$MOUNT_ROOT/public" "$MOUNT_ROOT/private"

mount_smbfs "//guest:@${NAS_HOST}/${NAS_PUBLIC_SHARE}" "$MOUNT_ROOT/public" 2>/dev/null || \
  warn "Public share already mounted or failed"

mount_smbfs "//${NAS_USER}:${NAS_PASS}@${NAS_HOST}/${NAS_PRIVATE_SHARE}" "$MOUNT_ROOT/private" 2>/dev/null || \
  warn "Private share already mounted or failed"
unset NAS_PASS
ok "NAS mounted"

# ── Expected directory tree ───────────────────────────────────
PUBLIC_DIRS=(
  "fonts/operator-mono-nerd-font"
  "fonts/averta"
  "fonts/circular-std"
  "fonts/other"
)

PRIVATE_DIRS=(
  "keyboard-maestro"
  "karabiner"
  "prefs/DEVONthink"
  "prefs/Fantastical"
  "prefs/ChronoSync"
  "prefs/Hazel"
  "prefs/Keyboard_Maestro"
  "captures"
)

# ── Verify mode ───────────────────────────────────────────────
if [[ "$VERIFY_ONLY" == "--verify" ]]; then
  echo ""
  echo "${BOLD}── NAS Layout Verification ──────────────────────────────${RESET}"
  echo ""
  echo "Public share (fonts, non-sensitive assets):"
  for d in "${PUBLIC_DIRS[@]}"; do
    [[ -d "$MOUNT_ROOT/public/$d" ]] && \
      echo "  ${GREEN}✓${RESET} $d ($(ls "$MOUNT_ROOT/public/$d" | wc -l | tr -d ' ') files)" || \
      echo "  ${YELLOW}✗${RESET} $d (missing)"
  done
  echo ""
  echo "Private share (auth required):"
  for d in "${PRIVATE_DIRS[@]}"; do
    [[ -d "$MOUNT_ROOT/private/$d" ]] && \
      echo "  ${GREEN}✓${RESET} $d ($(ls "$MOUNT_ROOT/private/$d" 2>/dev/null | wc -l | tr -d ' ') files)" || \
      echo "  ${YELLOW}✗${RESET} $d (missing)"
  done
  echo ""
  diskutil unmount "$MOUNT_ROOT/public" "$MOUNT_ROOT/private" 2>/dev/null || true
  exit 0
fi

# ── Create directory structure ────────────────────────────────
info "Creating directory structure on NAS..."
for d in "${PUBLIC_DIRS[@]}"; do
  mkdir -p "$MOUNT_ROOT/public/$d"
done
for d in "${PRIVATE_DIRS[@]}"; do
  mkdir -p "$MOUNT_ROOT/private/$d"
done
ok "Directories created"

# ── Copy fonts ────────────────────────────────────────────────
info "Copying licensed fonts from ~/Library/Fonts..."
echo ""

# Operator Mono Nerd Font — 4 specific weights
OPERATOR_FONTS=(
  "Operator Mono Book Nerd Font Complete.otf"
  "Operator Mono Book Italic Nerd Font Complete.otf"
  "Operator Mono Medium Nerd Font Complete.otf"
  "Operator Mono Medium Italic Nerd Font Complete.otf"
)
FONT_SRC="$HOME/Library/Fonts"
for f in "${OPERATOR_FONTS[@]}"; do
  src="$FONT_SRC/$f"
  dest="$MOUNT_ROOT/public/fonts/operator-mono-nerd-font/$f"
  if [[ -f "$src" ]]; then
    cp "$src" "$dest" && ok "  Operator Mono: $f"
  else
    warn "  Not found: $src"
  fi
done

# Averta family
find "$FONT_SRC" -name "Averta*.otf" -exec cp {} "$MOUNT_ROOT/public/fonts/averta/" \; 2>/dev/null
AVERTA_COUNT=$(ls "$MOUNT_ROOT/public/fonts/averta/" 2>/dev/null | wc -l | tr -d ' ')
ok "Averta: $AVERTA_COUNT files"

# Circular Std family
find "$FONT_SRC" -name "CircularStd*.otf" -exec cp {} "$MOUNT_ROOT/public/fonts/circular-std/" \; 2>/dev/null
CIRC_COUNT=$(ls "$MOUNT_ROOT/public/fonts/circular-std/" 2>/dev/null | wc -l | tr -d ' ')
ok "Circular Std: $CIRC_COUNT files"

# Other licensed fonts (Trade Gothic, Documan, Stellage, Minion Pro, Neue Haas)
for pattern in "trade-gothic*.ttf" "DocumanSTC*.otf" "Stellage*.otf" "MinionPro*.otf" "neuehaasgrot*.otf"; do
  find "$FONT_SRC" -name "$pattern" -exec cp {} "$MOUNT_ROOT/public/fonts/other/" \; 2>/dev/null
done
OTHER_COUNT=$(ls "$MOUNT_ROOT/public/fonts/other/" 2>/dev/null | wc -l | tr -d ' ')
ok "Other fonts: $OTHER_COUNT files"

# ── Copy Keyboard Maestro macro library ───────────────────────
info "Copying Keyboard Maestro macro library..."
KM_LIB="$HOME/Library/Application Support/Keyboard Maestro/Keyboard Maestro Macros.kmsync"
if [[ -f "$KM_LIB" ]]; then
  cp "$KM_LIB" "$MOUNT_ROOT/private/keyboard-maestro/"
  ok "Keyboard Maestro macros backed up"
else
  # Try the plist variant (non-synced libraries)
  KM_PLIST="$HOME/Library/Application Support/Keyboard Maestro/Keyboard Maestro Macros.plist"
  [[ -f "$KM_PLIST" ]] && \
    cp "$KM_PLIST" "$MOUNT_ROOT/private/keyboard-maestro/" && \
    ok "Keyboard Maestro macros (plist) backed up" || \
    warn "Keyboard Maestro macro library not found — configure sync path in macros"
fi

# ── Copy preference backups ───────────────────────────────────
info "Copying app preferences..."

# Find most recent capture archive on Desktop
CAPTURE=$(ls -dt "$HOME/Desktop/mac-capture-"*/ 2>/dev/null | head -1)
if [[ -n "$CAPTURE" ]]; then
  [[ -d "$CAPTURE/prefs/DEVONthink" ]]   && cp -r "$CAPTURE/prefs/DEVONthink/"*   "$MOUNT_ROOT/private/prefs/DEVONthink/"  2>/dev/null
  [[ -d "$CAPTURE/prefs/Fantastical" ]]  && cp -r "$CAPTURE/prefs/Fantastical/"*  "$MOUNT_ROOT/private/prefs/Fantastical/" 2>/dev/null
  [[ -d "$CAPTURE/prefs/ChronoSync" ]]   && cp -r "$CAPTURE/prefs/ChronoSync/"*   "$MOUNT_ROOT/private/prefs/ChronoSync/"  2>/dev/null
  [[ -d "$CAPTURE/prefs/Hazel" ]]        && cp -r "$CAPTURE/prefs/Hazel/"*        "$MOUNT_ROOT/private/prefs/Hazel/"       2>/dev/null
  [[ -d "$CAPTURE/prefs/Keyboard_Maestro" ]] && \
    cp -r "$CAPTURE/prefs/Keyboard_Maestro/"* "$MOUNT_ROOT/private/prefs/Keyboard_Maestro/" 2>/dev/null
  ok "Preferences copied from $CAPTURE"

  # Copy the full capture archive itself
  ARCHIVE=$(ls -t "$HOME/Desktop/mac-capture-"*.tar.gz 2>/dev/null | head -1)
  [[ -n "$ARCHIVE" ]] && \
    cp "$ARCHIVE" "$MOUNT_ROOT/private/captures/" && \
    ok "Capture archive: $(basename "$ARCHIVE")"
else
  warn "No capture archive found on Desktop — run scripts/capture.sh first"
fi

# ── Unmount ───────────────────────────────────────────────────
info "Unmounting NAS..."
diskutil unmount "$MOUNT_ROOT/public" "$MOUNT_ROOT/private" 2>/dev/null || true
ok "NAS unmounted"

# ── Summary ───────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║            NAS Setup Complete  📦                   ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "  Verify layout: ${BOLD}./scripts/nas-setup.sh --verify${RESET}"
echo ""
echo "  ${YELLOW}On Dogbert, run:${RESET}"
echo "    make nas          — pull all NAS assets"
echo "    make build TAGS=nas,fonts — fonts only"
echo ""
