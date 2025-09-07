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

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# bun completions
[ -s "/Users/rai/.bun/_bun" ] && source "/Users/rai/.bun/_bun"

[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"


alias claude="/Users/rai/.claude/local/claude"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Load Angular CLI autocompletion.
source <(ng completion script)
