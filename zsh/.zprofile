## ~/.zprofile - login-shell PATH fix (runs after /etc/zprofile's path_helper)
# Ensures Homebrew wins over /usr/bin in login shells (Terminal, tmux, IDEs).
# .zshenv runs BEFORE path_helper, so without this /usr/bin ends up first.
eval "$(/opt/homebrew/bin/brew shellenv)"
typeset -U PATH path
