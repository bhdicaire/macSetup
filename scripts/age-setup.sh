#!/usr/bin/env zsh
# ============================================================
# age-setup.sh — one-time age key generation
#
# Run this ONCE on Hal9000 BEFORE wiping.
# Generates an age keypair, stores the private key in 1Password
# as a secure document, and outputs the public key for you to
# commit in chezmoi.toml.
#
# On Dogbert, the playbook pulls the private key from 1Password
# automatically — you never copy it manually again.
#
# Prerequisites:
#   brew install age
#   op signin (1Password CLI authenticated)
#
# Usage:
#   chmod +x scripts/age-setup.sh
#   ./scripts/age-setup.sh
# ============================================================

set -euo pipefail

BOLD='\033[1m'; GREEN='\033[32m'; YELLOW='\033[33m'
BLUE='\033[34m'; RED='\033[31m'; RESET='\033[0m'

KEY_DIR="$HOME/.config/chezmoi"
KEY_FILE="$KEY_DIR/key.txt"
OP_ITEM_NAME="chezmoi age key"
OP_VAULT="Private"

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║         chezmoi age Encryption Setup               ║"
echo "║                                                      ║"
echo "║  Run ONCE on Hal9000 before wiping.                ║"
echo "║  Stores age private key in 1Password.              ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# ── Preflight ─────────────────────────────────────────────────
if ! command -v age-keygen &>/dev/null; then
  echo "${RED}✗ age not installed. Run: brew install age${RESET}"
  exit 1
fi

if ! op account list &>/dev/null; then
  echo "${RED}✗ 1Password CLI not authenticated. Run: eval \$(op signin)${RESET}"
  exit 1
fi

# ── Check for existing key ────────────────────────────────────
if op item get "$OP_ITEM_NAME" --vault "$OP_VAULT" &>/dev/null; then
  echo "${YELLOW}⚠  '${OP_ITEM_NAME}' already exists in 1Password vault '${OP_VAULT}'.${RESET}"
  echo ""
  read -r -p "  Overwrite? This will break decryption of existing encrypted dotfiles. [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
fi

# ── Generate keypair ──────────────────────────────────────────
echo "${BLUE}→${RESET} Generating age keypair..."
mkdir -p "$KEY_DIR"
chmod 700 "$KEY_DIR"

age-keygen -o "$KEY_FILE"
chmod 600 "$KEY_FILE"

PUBLIC_KEY=$(grep '^# public key:' "$KEY_FILE" | awk '{print $NF}')
echo "${GREEN}✓${RESET} Keypair generated"
echo ""
echo "  Public key: ${BOLD}${PUBLIC_KEY}${RESET}"
echo "  Private key: ${KEY_FILE} (never commit this)"
echo ""

# ── Store in 1Password ────────────────────────────────────────
echo "${BLUE}→${RESET} Storing private key in 1Password..."

op document create "$KEY_FILE" \
  --title "$OP_ITEM_NAME" \
  --vault "$OP_VAULT" \
  --tags "chezmoi,encryption,dotfiles" \
  2>/dev/null && echo "${GREEN}✓${RESET} Private key stored in 1Password vault '${OP_VAULT}'" \
  || {
    echo "${RED}✗ Failed to store in 1Password. Trying update...${RESET}"
    ITEM_ID=$(op item get "$OP_ITEM_NAME" --vault "$OP_VAULT" --format json | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])')
    op document edit "$ITEM_ID" "$KEY_FILE" --vault "$OP_VAULT"
    echo "${GREEN}✓${RESET} Private key updated in 1Password"
  }

# ── Store public key as a separate 1Password field ────────────
op item edit "$OP_ITEM_NAME" \
  --vault "$OP_VAULT" \
  "public_key[text]=${PUBLIC_KEY}" \
  2>/dev/null || true

# ── Update chezmoi.toml ───────────────────────────────────────
CHEZMOI_TOML="$HOME/.config/chezmoi/chezmoi.toml"

if [[ -f "$CHEZMOI_TOML" ]]; then
  echo ""
  echo "${BLUE}→${RESET} Updating chezmoi.toml with new public key..."
  # Replace recipient line
  sed -i '' "s|recipient = \".*\"|recipient = \"${PUBLIC_KEY}\"|" "$CHEZMOI_TOML" && \
    echo "${GREEN}✓${RESET} chezmoi.toml updated"
else
  echo ""
  echo "${YELLOW}⚠  ~/.config/chezmoi/chezmoi.toml not found.${RESET}"
  echo "   Add this to your chezmoi.toml [age] section:"
  echo ""
  echo "   [age]"
  echo "       identity  = \"$KEY_FILE\""
  echo "       recipient = \"${PUBLIC_KEY}\""
fi

# ── Commit public key to dotFiles repo ───────────────────────
CHEZMOI_SOURCE="$(chezmoi source-path 2>/dev/null || echo "$HOME/.local/share/chezmoi")"
CHEZMOI_TOML_TMPL="$CHEZMOI_SOURCE/.chezmoi.toml.tmpl"

if [[ -f "$CHEZMOI_TOML_TMPL" ]]; then
  echo ""
  echo "${BLUE}→${RESET} Updating .chezmoi.toml.tmpl with public key..."
  sed -i '' "s|recipient = \".*\"|recipient = \"${PUBLIC_KEY}\"|" "$CHEZMOI_TOML_TMPL" && \
    echo "${GREEN}✓${RESET} .chezmoi.toml.tmpl updated"
  echo ""
  echo "  Commit this change:"
  echo "  ${BOLD}cd $CHEZMOI_SOURCE && git add .chezmoi.toml.tmpl && git commit -m 'feat(age): update encryption recipient key'${RESET}"
fi

# ── Encrypt existing private files ───────────────────────────
echo ""
echo "${BLUE}→${RESET} Encrypting private dotfiles..."
echo ""

PRIVATE_FILES=(
  "$HOME/.ssh/config.local"
  "$HOME/.aws/credentials"
  "$HOME/.config/gh/hosts.yml"
)

for f in "${PRIVATE_FILES[@]}"; do
  if [[ -f "$f" ]]; then
    echo -n "  Encrypting $f ... "
    chezmoi add --encrypt "$f" 2>/dev/null && \
      echo "${GREEN}✓${RESET}" || echo "${YELLOW}skipped (may already be managed)${RESET}"
  else
    echo "  ${YELLOW}⚠  $f not found — skip${RESET}"
  fi
done

# ── Summary ───────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║              Age Setup Complete  🔐                 ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "  ${BOLD}Public key:${RESET}   ${PUBLIC_KEY}"
echo "  ${BOLD}Private key:${RESET}  ${KEY_FILE} (also in 1Password: '${OP_ITEM_NAME}')"
echo ""
echo "  ${YELLOW}Before wiping Hal9000:${RESET}"
echo "  ☐ Push dotFiles changes to GitHub"
echo "  ☐ Verify 1Password has the key: op document get '${OP_ITEM_NAME}'"
echo "  ☐ Test decryption on a second machine (optional but smart)"
echo ""
echo "  ${YELLOW}On Dogbert, the playbook will:${RESET}"
echo "  1. Pull private key from 1Password automatically"
echo "  2. Run chezmoi apply → decrypt all .age files transparently"
echo ""
