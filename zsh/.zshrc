## /.config/zsh/.zshrc
# Main Zsh configuration file that loads all modular configs

# Enable Starship's instant prompt
# export STARSHIP_LOG="error"
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/starship/init.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/starship/init.zsh"
fi

# Source Deno environment
. "/Users/rai/.deno/env"

# Source local environment
. "$HOME/.local/bin/env"

# Load all modular configurations
for conf in "$ZDOTDIR/conf.d/"*.zsh; do
    source "$conf"
done
