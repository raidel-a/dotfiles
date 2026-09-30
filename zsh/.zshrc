## /.config/zsh/.zshrc
# Main Zsh configuration file that loads all modular configs
# NOTE: CLI installers (Kiro, nvm, etc.) must NOT append blocks here.
# Put tool init in conf.d/ instead (see 00-kiro-pre.zsh, 99-kiro-post.zsh,
# plugins.zsh). If an installer re-adds blocks here, move them to conf.d/.

# Enable Starship's instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/starship/init.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/starship/init.zsh"
fi

# Load all modular configurations
for conf in "$ZDOTDIR/conf.d/"*.zsh; do
    source "$conf"
done
eval "$(~/.local/bin/mise activate zsh)"

# Final PATH sweep (2026-09-15 overhaul): purge legacy inherits re-added after
# path.zsh by parent env / tool hooks, then dedupe. Keeps new shells clean
# even when launched from an old shell with stale PATH exports.
unset FNM_MULTISHELL_PATH FNM_DIR FNM_ARCH FNM_COREPACK_ENABLED FNM_LOGLEVEL \
  FNM_NODE_DIST_MIRROR FNM_RESOLVE_ENGINES FNM_VERSION_FILE_STRATEGY \
  NVM_BIN NVM_CD_FLAGS NVM_DIR NVM_INC 2>/dev/null
path=(${path:#*/fnm_multishells/*})
path=(${path:#*/.nvm/*})
path=(${path:#$HOME/Library/Python/*/bin})
path=(${path:#/opt/anaconda3/bin})
path=(${path:#$HOME/.spicetify})
path=(${path:#\~/.dotnet/tools})
path=(${path:#$HOME/.dotnet/tools})
typeset -U PATH path
export PATH
