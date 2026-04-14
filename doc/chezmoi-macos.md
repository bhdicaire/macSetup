# Extending dotFiles for macOS

Your existing `bhdicaire/dotFiles` repo targets Debian headless servers.
This guide shows how to add macOS-specific configuration without forking
or creating a separate repo — chezmoi's template system handles the split cleanly.

## Strategy: OS guards in templates

chezmoi exposes `.chezmoi.os` (`darwin` / `linux`) and `.chezmoi.arch` (`arm64` / `amd64`)
in all templates. Use these to include macOS-specific blocks.

## Files to add or modify

### 1. `dot_zshenv` → `dot_zshenv.tmpl`

Rename and add macOS-specific PATH entries:

```
# Homebrew (Apple Silicon)
{{ if eq .chezmoi.os "darwin" -}}
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
{{ end -}}

# Common
export EDITOR="bbedit --wait"
export VISUAL="$EDITOR"
```

### 2. `dot_config/zsh/aliases.zsh.tmpl` (new file)

```
{{ if eq .chezmoi.os "darwin" -}}
# macOS aliases
alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
alias ldd="otool -L"          # macOS equivalent of ldd

# Applications shortcuts
alias bbedit="/usr/local/bin/bbedit"
alias preview="open -a Preview"
alias finder="open -a Finder ."
alias chrome="open -a 'Google Chrome'"

# Homebrew
alias buu="brew update && brew upgrade && brew cleanup"
alias bdoc="brew doctor"
{{ end -}}
```

### 3. `dot_config/starship.toml.tmpl`

Make the prompt macOS-aware (already in dotFiles but may need macOS-specific modules):

```toml
{{ if eq .chezmoi.os "darwin" -}}
[battery]
disabled = false

[[battery.display]]
threshold = 20
style = "bold red"
{{ end -}}
```

### 4. New macOS-only file: `dot_config/zsh/macos.zsh.tmpl`

```
{{ if eq .chezmoi.os "darwin" -}}
# ── macOS-specific Zsh config ────────────────────────────────

# 1Password SSH agent
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# Homebrew completions
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# iTerm2 / Terminal integration
[[ "$TERM_PROGRAM" == "iTerm.app" ]] && source ~/.iterm2_shell_integration.zsh 2>/dev/null || true
{{ end -}}
```

### 5. `.chezmoiignore` additions

Add to your existing `.chezmoiignore`:

```
{{ if ne .chezmoi.os "darwin" -}}
dot_config/zsh/macos.zsh.tmpl
{{ end -}}
```

## Applying the changes

```bash
# On macOS (after macSetup runs)
chezmoi init --apply https://github.com/bhdicaire/dotFiles.git

# Verify OS detection
chezmoi data | grep os

# Check what would change
chezmoi diff

# Apply
chezmoi apply --verbose
```

## Secrets in templates

chezmoi integrates with 1Password natively. Example in a template:

```
# ~/.config/git/config (from dot_config/git/config.tmpl)
[user]
  name  = {{ .name }}
  email = {{ .email }}
  signingkey = {{ onepasswordDetailsFields "SSH Keys" "public key" "Personal" | .value }}
```

Configure in `~/.config/chezmoi/chezmoi.toml`:

```toml
[onepassword]
  command = "op"
  prompt  = false
```

## Testing the setup

```bash
# Dry run — show what would change
chezmoi apply --dry-run --verbose

# Verify template rendering
chezmoi execute-template < dot_config/zsh/macos.zsh.tmpl

# See final config
chezmoi cat dot_config/zsh/macos.zsh.tmpl
```
