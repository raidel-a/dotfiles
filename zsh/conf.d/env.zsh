# Environment configurations

# Deno environment
[[ -f "$HOME/.deno/env" ]] && . "$HOME/.deno/env"

# Local bin environment
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# OrbStack integration
[[ -f "$HOME/.orbstack/shell/init.zsh" ]] && . "$HOME/.orbstack/shell/init.zsh"

# Git
export GIT_CONFIG_GLOBAL="$HOME/.config/git/config"
