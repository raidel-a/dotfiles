# Aliases and related configurations

# CLI tool aliases
alias sp="/opt/homebrew/bin/spotify_player"
alias wl="wishlist"
alias ld='lazydocker'
alias lg='lazygit'
alias oc='opencode'
alias oc2='opencode2'

# File listing (eza)
alias ls="eza --icons=always -F --color=always"
alias lsa="eza --icons=always -F --color=always -a"
alias ll="eza --icons=always -F --color=always -l --git"
alias la="eza --icons=always -F --color=always -a"
alias lt="eza --icons=always -F --color=always --tree --level=2"

# Navigation
alias cd="z"

# Safe deletion - send files to Trash instead of permanent deletion
# NOTE: PATH prepend moved to conf.d/path.zsh (centralized) 2026-09-15
alias rm="trash"
alias rmreal="/bin/rm"  # use this for actual rm when needed

#  Navigates to directory and lists all contents (including hidden files)
cdl() {
    if [ -z "$1" ]; then
        cd ~ && lsa
    elif [ -d "$1" ]; then
        cd "$1" && lsa
    else
        echo "Error: Directory '$1' does not exist."
    fi
}
# Creates directory and navigates into it
md() {
    mkdir -p -- "$1" && z "$1"
}
