## /zsh/.zshenv

# zshrc is also sourced when the shell is started programatically

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

# Path configuration
export DOTFILESPATH="$HOME/.config"
export GOROOT="$(brew --prefix go)/libexec"
export GOPATH="$HOME/.go"

# Path additions
export PATH="$DOTFILESPATH/bin:$GOROOT/bin:$GOPATH/bin:$PATH"
export PATH="$PATH:/Users/rai/Library/Python/3.12/bin"

# Homebrew initialization
eval "$(/opt/homebrew/bin/brew shellenv)"

# Custom directories
export SCREENSHOT="$HOME/Pictures/Screenshots"
