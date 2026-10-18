#!/usr/bin/env bash
# ============================================================
# bootstrap.sh — the steps a fresh Mac needs before mac-fleet can run
#
# Two modes, because the two kinds of Mac start differently:
#
#   --control-node    The laptop that runs Ansible on itself (dogbert).
#                     Command line tools, Homebrew from its signed .pkg,
#                     the tools that bring up 1Password, chezmoi and Ansible,
#                     and the pinned Forgejo SSH host key. Remote Login is
#                     never touched: it stays off on a laptop.
#
#   --managed-target  A Mac managed over SSH from the control node (maestro).
#                     Command line tools (for /usr/bin/python3), Remote Login
#                     on, and the admin key in authorized_keys. Everything
#                     else is the playbook's job.
#
# Delivery: a fresh Mac has no credentials, so it cannot clone this private
# repo. Fetch this file from the published copy at a fixed commit and check
# its sha256 against docs/NEW-MACHINE.md before running it. Never pipe it to
# a shell from a branch URL.
#
# Usage:
#   bash bootstrap.sh --control-node
#   bash bootstrap.sh --managed-target
# ============================================================
set -euo pipefail

# Homebrew release installed by --control-node; bump deliberately. The .pkg
# must pass Gatekeeper (Developer ID signed and notarized) before it is
# installed, and its signer is printed for the person running this.
HOMEBREW_VERSION="7.0.9"
HOMEBREW_PKG_URL="https://github.com/Homebrew/brew/releases/download/${HOMEBREW_VERSION}/Homebrew-${HOMEBREW_VERSION}.pkg"

# Forgejo SSH host key (git-ssh.d5e.dev), ED25519
# SHA256:a9zHLbZa+k6ZMet98ntPXQ0FwpFPnvk5+uIFHTizs58. Taken from dogbert's
# known_hosts on 2026-10-18; re-check on the Forgejo console when it rotates.
FORGEJO_HOST_KEY="git-ssh.d5e.dev ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8JmVDXZ69ss/jXidL/glYv4UBzLkiKwxnoFiSfiv1i"

# Formulae and casks the control node needs before chezmoi and Ansible can
# run. mac-fleet installs everything else.
CONTROL_FORMULAE=(git chezmoi age ansible 1password-cli)
CONTROL_CASKS=(1password)

BOLD=$(printf '\033[1m');   RESET=$(printf '\033[0m')
GREEN=$(printf '\033[32m'); YELLOW=$(printf '\033[33m'); RED=$(printf '\033[31m')

step() { echo; echo "${BOLD}▶ $*${RESET}"; }
ok()   { echo "${GREEN}  ✓ $*${RESET}"; }
warn() { echo "${YELLOW}  ⚠ $*${RESET}"; }
die()  { echo "${RED}  ✗ $*${RESET}"; exit 1; }

usage() { sed -n '2,27p' "$0" | sed 's/^# \{0,1\}//'; exit 2; }

[[ "$(uname -s)" == Darwin ]] || die "macOS only."
[[ $# -eq 1 ]] || usage
MODE="$1"
case "$MODE" in
  --control-node|--managed-target) ;;
  *) usage ;;
esac

# ── Xcode Command Line Tools (both modes) ─────────────────────
# Cannot be automated: `xcode-select --install` opens a GUI dialog and returns
# immediately. Also the source of /usr/bin/python3, which Ansible needs.
step "Xcode Command Line Tools"
if xcode-select --print-path &>/dev/null; then
  ok "Present at $(xcode-select --print-path)"
else
  echo "  A GUI prompt will appear. Click Install, then wait."
  xcode-select --install 2>/dev/null || true
  until xcode-select --print-path &>/dev/null; do
    sleep 5
    echo "  waiting..."
  done
  ok "Installed"
fi
[[ -x /usr/bin/python3 ]] || die "/usr/bin/python3 missing after the CLT install; Ansible cannot run."
ok "python3 $(/usr/bin/python3 -V 2>&1 | awk '{print $2}') (Ansible interpreter)"

control_node() {
  step "Homebrew ${HOMEBREW_VERSION}"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    ok "Present: $(/opt/homebrew/bin/brew --version | head -1)"
  else
    local dir pkg
    dir="$(mktemp -d)"
    pkg="${dir}/Homebrew.pkg"
    curl -fsSL --proto '=https' --tlsv1.2 -o "$pkg" "$HOMEBREW_PKG_URL" \
      || die "Download failed: $HOMEBREW_PKG_URL"
    spctl --assess --type install "$pkg" \
      || die "Gatekeeper rejected Homebrew.pkg (not notarized). Not installing."
    pkgutil --check-signature "$pkg" | sed -n '2,4p'
    sudo installer -pkg "$pkg" -target /
    rm -rf "$dir"
    ok "Installed"
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"

  step "Control-node tools"
  brew install "${CONTROL_FORMULAE[@]}"
  brew install --cask "${CONTROL_CASKS[@]}"
  ok "${CONTROL_FORMULAE[*]} ${CONTROL_CASKS[*]}"

  # Pinned, so the first clone cannot trust whatever answers (AGENTS.md:
  # verified SSH host keys).
  step "Forgejo SSH host key"
  mkdir -p "${HOME}/.ssh" && chmod 700 "${HOME}/.ssh"
  touch "${HOME}/.ssh/known_hosts" && chmod 600 "${HOME}/.ssh/known_hosts"
  if grep -qxF "$FORGEJO_HOST_KEY" "${HOME}/.ssh/known_hosts"; then
    ok "Already pinned"
  else
    echo "$FORGEJO_HOST_KEY" >> "${HOME}/.ssh/known_hosts"
    ok "Pinned git-ssh.d5e.dev"
  fi

  cat <<DONE

${BOLD}Control node ready.${RESET} Continue with docs/NEW-MACHINE.md section 3:
open 1Password, turn on the CLI integration and the SSH agent, then

  export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
  ssh -o StrictHostKeyChecking=yes -T git@git-ssh.d5e.dev

DONE
}

managed_target() {
  # Chicken-and-egg: no SSH means no Ansible means nothing can turn SSH on.
  # The playbook manages the user restriction afterwards.
  step "Remote Login (SSH)"
  if sudo launchctl print system/com.openssh.sshd &>/dev/null; then
    ok "Already enabled"
  else
    sudo systemsetup -setremotelogin on \
      || die "Failed. Enable it in System Settings, General, Sharing, Remote Login.
              On recent macOS this command needs Full Disk Access for Terminal."
    ok "Enabled"
  fi

  # The public half of `<host>-bhdicaire-ssh` (1Password, homeLab automation).
  # Cannot arrive over SSH, because it is what makes SSH work.
  step "authorized_keys"
  local auth="${HOME}/.ssh/authorized_keys" host
  host="$(scutil --get LocalHostName 2>/dev/null || hostname -s)"
  mkdir -p "${HOME}/.ssh" && chmod 700 "${HOME}/.ssh"
  touch "$auth" && chmod 600 "$auth"
  if [[ -s "$auth" ]]; then
    ok "$auth already has $(wc -l < "$auth" | tr -d ' ') key(s)"
  else
    warn "$auth is empty."
    echo "  On the control node, copy the PUBLIC key:"
    echo "    ${BOLD}op read --account dicaire 'op://homeLab automation/${host}-bhdicaire-ssh/public key' | pbcopy${RESET}"
    echo "  Then paste it into $auth on this machine and re-run."
  fi

  cat <<DONE

${BOLD}Managed target ready.${RESET} From the control node:

  ansible-playbook macos/mac-fleet/playbooks/site.yml --limit ${host} --check
  ansible-playbook macos/mac-fleet/playbooks/site.yml --limit ${host}

Manual steps that need a human on this machine: docs/MANUAL_STEPS.md.
DONE
}

case "$MODE" in
  --control-node)   control_node ;;
  --managed-target) managed_target ;;
esac
