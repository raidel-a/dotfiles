## /zsh/.zshenv

# Initialize Homebrew first
eval "$(/opt/homebrew/bin/brew shellenv)"

# XDG Base Directory specification
export XDG_CONFIG_HOME="$HOME/.config"
export ZSHCONFIG="$HOME/.config/zsh"
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
export DOTFILESPATH="$HOME/.config"
export PATH="$DOTFILESPATH/bin:$PATH"
export PATH="$PATH:/Users/rai/Library/Python/3.10/bin"

# Custom directories
export SCREENSHOT="$HOME/Pictures/Screenshots"

# Add Visual Studio Code (code)
export PATH="\$PATH:/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin"

