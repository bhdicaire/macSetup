# ============================================================
# Makefile — macSetup
# ============================================================
# make build              full provisioning run
# make build TAGS=brew    only Homebrew
# make build TAGS=nas     only NAS assets
# make capture            snapshot Hal9000 before wiping
# make age-setup          generate age key, store in 1Password
# make nas-setup          initialise NAS share structure
# make nas                pull NAS assets only
# make setapp             guided SetApp app installer
# make lint               yamllint + ansible-lint
# make info               machine state summary
# ============================================================

SHELL       := /bin/zsh
.DEFAULT_GOAL := help

BREW        := /opt/homebrew/bin/brew
ANSIBLE     := /opt/homebrew/bin/ansible-playbook
GALAXY      := /opt/homebrew/bin/ansible-galaxy
YAMLLINT    := /opt/homebrew/bin/yamllint
ANLINT      := /opt/homebrew/bin/ansible-lint

BOLD   := \033[1m
BLUE   := \033[34m
GREEN  := \033[32m
YELLOW := \033[33m
RESET  := \033[0m

.PHONY: help build bootstrap capture age-setup nas-setup nas setapp \
        lint galaxy info check clean dry-run debug chezmoi-apply chezmoi-diff \
        karabiner

help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / \
	  {printf "$(BLUE)%-18s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# ── Provisioning ──────────────────────────────────────────────

bootstrap: ## Run bootstrap.sh on a fresh machine
	@echo "$(BOLD)$(BLUE)▶ Bootstrap$(RESET)"
	bash scripts/bootstrap.sh

build: check ## Run full Ansible playbook
	@echo "$(BOLD)$(BLUE)▶ Full provisioning run$(RESET)"
ifdef TAGS
	$(ANSIBLE) macSetup.yml --tags "$(TAGS)"
else
	$(ANSIBLE) macSetup.yml
endif

debug: ## Run with -vvvv verbosity
	$(ANSIBLE) macSetup.yml -vvvv

dry-run: check ## Check mode — no changes applied
	$(ANSIBLE) macSetup.yml --check --diff

# ── Pre-wipe (run on Hal9000) ─────────────────────────────────

capture: ## Snapshot current Mac before wiping
	@echo "$(BOLD)$(YELLOW)▶ Capturing current Mac configuration$(RESET)"
	bash scripts/capture.sh

age-setup: ## Generate age key and store in 1Password (run on Hal9000 once)
	@echo "$(BOLD)$(BLUE)▶ age encryption setup$(RESET)"
	bash scripts/age-setup.sh

nas-setup: ## Initialise NAS share structure and populate from current Mac
	@echo "$(BOLD)$(BLUE)▶ NAS setup$(RESET)"
	bash scripts/nas-setup.sh

nas-verify: ## Verify NAS share layout without copying
	bash scripts/nas-setup.sh --verify

# ── Post-install ──────────────────────────────────────────────

nas: check ## Pull NAS assets (fonts, KM macros, prefs)
	@echo "$(BOLD)$(BLUE)▶ NAS asset pull$(RESET)"
	$(ANSIBLE) macSetup.yml --tags nas

setapp: ## Guided SetApp application installer
	@echo "$(BOLD)$(BLUE)▶ SetApp guided install$(RESET)"
	bash scripts/setapp-install.sh

# ── Dotfiles ──────────────────────────────────────────────────

chezmoi-apply: ## Apply dotfiles via chezmoi
	@echo "$(BOLD)$(BLUE)▶ chezmoi apply$(RESET)"
	/opt/homebrew/bin/chezmoi apply --verbose

chezmoi-diff: ## Show pending chezmoi changes
	/opt/homebrew/bin/chezmoi diff

karabiner: ## Apply Karabiner config from chezmoi
	/opt/homebrew/bin/chezmoi apply $$HOME/.config/karabiner/karabiner.json

# ── Quality ───────────────────────────────────────────────────

lint: ## Run yamllint + ansible-lint
	@echo "$(BOLD)$(BLUE)▶ Linting$(RESET)"
	$(YAMLLINT) . && echo "$(GREEN)✓ yamllint$(RESET)"
	$(ANLINT) --force-color . && echo "$(GREEN)✓ ansible-lint$(RESET)"

galaxy: ## Update Ansible Galaxy collections
	$(GALAXY) collection install -r requirements.yml --upgrade

# ── Information ───────────────────────────────────────────────

info: ## Show current machine state
	@echo ""
	@echo "$(BOLD)── Machine ───────────────────────────────────────$(RESET)"
	@echo "Computer Name  : $$(scutil --get ComputerName 2>/dev/null)"
	@echo "LocalHostName  : $$(scutil --get LocalHostName 2>/dev/null)"
	@echo "macOS           : $$(sw_vers -productVersion) ($$(sw_vers -buildVersion))"
	@echo "Architecture   : $$(uname -m)"
	@echo "User / Shell   : $$USER  $$SHELL"
	@echo ""
	@echo "$(BOLD)── Homebrew ──────────────────────────────────────$(RESET)"
	@$(BREW) --version 2>/dev/null | head -1
	@echo "Formulae : $$($(BREW) list --formula 2>/dev/null | wc -l | tr -d ' ')"
	@echo "Casks    : $$($(BREW) list --cask 2>/dev/null | wc -l | tr -d ' ')"
	@echo ""
	@echo "$(BOLD)── Dotfiles ──────────────────────────────────────$(RESET)"
	@/opt/homebrew/bin/chezmoi status 2>/dev/null | head -20 || echo "(chezmoi not initialised)"
	@echo ""
	@echo "$(BOLD)── NAS ───────────────────────────────────────────$(RESET)"
	@ping -c 1 -W 2 nas.local &>/dev/null && echo "nas.local : reachable" || echo "nas.local : unreachable"
	@echo ""
	@echo "$(BOLD)── 1Password ─────────────────────────────────────$(RESET)"
	@op account list 2>/dev/null | head -3 || echo "(not authenticated)"
	@echo ""

# ── Utilities ─────────────────────────────────────────────────

check: ## Verify prerequisites
	@[[ -x "$(BREW)" ]]    || { echo "Homebrew not found. Run: make bootstrap"; exit 1; }
	@[[ -x "$(ANSIBLE)" ]] || { echo "ansible-playbook not found. Run: make bootstrap"; exit 1; }
	@op account list &>/dev/null || { echo "1Password CLI not authenticated. Run: eval \$$(op signin)"; exit 1; }
	@echo "$(GREEN)✓ Prerequisites met$(RESET)"

clean: ## Remove logs and generated files
	@rm -f /tmp/macSetup.log group_vars/secrets.yml
	@echo "$(GREEN)✓ Cleaned$(RESET)"

