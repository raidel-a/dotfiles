# Path configuration - centralized, idempotent, ordered
# Order intent: mise shims > Homebrew > user bins > Go/Rust/Bun > /usr/local > system (path_helper)
# All prepends are guarded; duplicates removed at the end via typeset -U.

# Dedupe PATH (keeps first occurrence)
typeset -U PATH path

# Purge legacy entries inherited from old sessions / parent env (2026-09-15 overhaul)
# Removes: fnm multishells, nvm versions, legacy ~/Library/Python, anaconda
path=(${path:#*/fnm_multishells/*})
path=(${path:#*$HOME/.nvm/*})
path=(${path:#$HOME/Library/Python/*/bin})
path=(${path:#/opt/anaconda3/bin})
export PATH="${(j.:.)path}"

# Helper: prepend only if dir exists and not already in PATH
path_prepend() {
  [[ -d "$1" ]] || return 0
  case ":${PATH}:" in
    *:"$1":*) ;;
    *) export PATH="$1:$PATH" ;;
  esac
}

# Helper: append only if dir exists and not already in PATH
path_append() {
  [[ -d "$1" ]] || return 0
  case ":${PATH}:" in
    *:"$1":*) ;;
    *) export PATH="$PATH:$1" ;;
  esac
}

# XDG user bins (high priority, override system)
# NOTE: merged 2026-09-15 — ~/.config/bin was empty, ~/.local/bin is canonical.
path_prepend "$HOME/.local/bin"

# Homebrew - re-assert after /etc/zprofile/path_helper and /usr/local prepends
# (.zshenv + ~/.zprofile already ran brew shellenv; this keeps interactive order correct)
path_prepend "/opt/homebrew/sbin"
path_prepend "/opt/homebrew/bin"

# Go (uses HOMEBREW_PREFIX from .zshenv brew shellenv)
export GOROOT="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/go/libexec"
export GOPATH="$HOME/.go"
path_prepend "$GOPATH/bin"
[[ -d "$GOROOT/bin" ]] && path_prepend "$GOROOT/bin"

# Rust / Bun / Node-adjacent
path_prepend "$HOME/.bun/bin"
path_prepend "$HOME/.opencode/bin"
path_prepend "$HOME/.deno/bin"
path_append "$HOME/.cargo/bin"

# Trash CLI (safe-rm replacement)
path_prepend "/opt/homebrew/opt/trash/bin"

# Intel / manual prefix - after brew so ARM brew wins
path_prepend "/usr/local/bin"

# Low-priority appends (kept for compat, not shadowing)
path_append "$HOME/.turso"
path_append "$HOME/.orbstack/bin"
# NOTE: removed ~/.spicetify (dir does not exist, `command -v spicetify` empty)
# NOTE: removed ~/Library/Python/*/bin (legacy 2.7/3.9/3.11/3.12) - use brew/mise python
# NOTE: removed /opt/anaconda3/bin (does not exist on this machine)

# Library paths
export DYLD_FALLBACK_LIBRARY_PATH="${HOMEBREW_PREFIX:-/opt/homebrew}/lib:${DYLD_FALLBACK_LIBRARY_PATH:-}"

# EZA configuration
export EZA_CONFIG_DIR="${XDG_CONFIG_HOME}/eza"

# Final dedupe
typeset -U PATH path
