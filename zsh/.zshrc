## /.config/zsh/.zshrc
# Main Zsh configuration file that loads all modular configs

# Source Deno environment
. "/Users/rai/.deno/env"

# Source local environment
. "$HOME/.local/bin/env"

# Load all modular configurations
for conf in "$ZDOTDIR/conf.d/"*.zsh; do
    source "$conf"
done
