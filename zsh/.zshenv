## /zsh/.zshenv

# zshrc is also sourced when the shell is started programatically

# make homebrew and its libraries available
eval "$(/opt/homebrew/bin/brew shellenv)"

# don't set ZDOTDIR to this directory, to not save cache files/history here
export ZSHCONFIG="$HOME/.config/zsh"
export XDG_CONFIG_HOME="$HOME/.config"
export ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}"
export HISTFILE="$ZDOTDIR/.zhistory"
export HISTSIZE=10000 
export SAVEHIST=10000
export VIMCONFIG="$XDG_CONFIG_HOME/nvim"
export SCREENSHOT="$HOME/Pictures/Screenshots"

# set default editor
export EDITOR=nvim
# _auto_restart
export VISUAL=nvim
# _auto_restart

# should not be necessary if the program is in the path? but check if maybe node doesn't add it?
# export LAUNCH_EDITOR=launch_nvim

# add ~/.config/bin to path and then export to sub-processes can use it
export DOTFILESPATH="$HOME/.config"

# add go related stuff to the path
export GOROOT="$(brew --prefix go)/libexec"
export GOPATH="$HOME/.go"

export PATH="$DOTFILESPATH/bin:$GOROOT/bin:$GOPATH/bin:$PATH"
