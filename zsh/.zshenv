## /zsh/.zshenv

# Initialize Homebrew first
eval "$(/opt/homebrew/bin/brew shellenv)"

# Cache Homebrew prefix for performance
export HOMEBREW_PREFIX="$(brew --prefix)"

# XDG Base Directory specification
export XDG_CONFIG_HOME="$HOME/.config"
export ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}"
export VIMCONFIG="$XDG_CONFIG_HOME/nvim"

# History configuration
export HISTFILE="$ZDOTDIR/.zhistory"
export HISTSIZE=10000
export SAVEHIST=10000

# Editor configuration
export EDITOR=nvim
export VISUAL=nvim

# Base path configuration
export PATH="$XDG_CONFIG_HOME/bin:$PATH"

# Python user binaries (version-agnostic)
for python_bin in $HOME/Library/Python/*/bin; do
  [[ -d "$python_bin" ]] && export PATH="$PATH:$python_bin"
done

# Custom directories
export SCREENSHOT="$HOME/Pictures/Screenshots"

# Visual Studio Code (only if installed)
[[ -d "/Applications/Visual Studio Code - Insiders.app" ]] && \
  export PATH="$PATH:/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin"

