## /zsh/.zshenv

# Initialize Homebrew first
eval "$(/opt/homebrew/bin/brew shellenv)"

# Cache Homebrew prefix for performance
export HOMEBREW_PREFIX="$(brew --prefix)"

# XDG Base Directory specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}"
export VIMCONFIG="$XDG_CONFIG_HOME/nvim"

# XDG relocations (2026-09-15 home-declutter)
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export PYTHONHISTORY="$XDG_STATE_HOME/python/history"
export SQLITE_HISTORY="$XDG_STATE_HOME/sqlite/history"
# NOTE: no VIMINIT here (2026-09-15 fix) - nvim reads $VIMINIT too and aliases
# viminfofile to its shada path, which corrupts both. Legacy vim is redirected
# via ~/.vimrc instead (vim-only file, nvim ignores it).

# History configuration
export HISTFILE="$ZDOTDIR/.zhistory"
export HISTSIZE=10000
export SAVEHIST=10000

# Editor configuration
export EDITOR=nvim
export VISUAL=nvim

# NOTE: former $XDG_CONFIG_HOME/bin prepend removed 2026-09-15 (bin dirs merged:
# ~/.config/bin was empty; ~/.local/bin is canonical and already prepended in path.zsh).

# NOTE: legacy ~/Library/Python/*/bin entries removed 2026-09-15 (full PATH overhaul,
# standardize on brew/mise python). Old loop kept in git/backup at ~/.config/zsh.bak.*.

# Custom directories
export SCREENSHOT="$HOME/Pictures/Screenshots"

# Visual Studio Code (only if installed)
[[ -d "/Applications/Visual Studio Code - Insiders.app" ]] && \
  export PATH="$PATH:/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin"

