## /.config/zsh/.zshrc

# zshrc is only sourced for interactive shells

eval "$(direnv hook zsh)"

eval "$(fnm env --use-on-cd)"

# alias oce="wezterm ssh ralme023@ocelot.aul.fiu.edu"
# alias zeph="wezterm ssh raihv@110.0.0.228"
alias sp="/opt/homebrew/bin/spotify_player"
alias wl="wishlist"
alias lzd='lazydocker'

eval "$(starship init zsh)"

. "/Users/rai/.deno/env"

export PATH="/usr/local/bin:$PATH"

export PATH=$PATH:/Users/rai/.spicetify

export DYLD_FALLBACK_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_FALLBACK_LIBRARY_PATH"

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# ---- Eza (better ls) -----

alias ls="eza --icons=always"

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"

alias cd="z"


# bun completions
[ -s "/Users/rai/.bun/_bun" ] && source "/Users/rai/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"



# Turso
export PATH="$PATH:/Users/rai/.turso"

. "$HOME/.local/bin/env"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/rai/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
