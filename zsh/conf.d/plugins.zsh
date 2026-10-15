# Plugin configurations

# zsh-vi-mode (Homebrew): near-native vim editing - text objects, surround,
# visual mode, system clipboard. Sourced FIRST so its init sees clean keymaps.
# ZVM_INIT_MODE=sourcing initializes at source time; the default lazy init
# would overwrite keybindings of plugins sourced below (fzf, autosuggestions).
ZVM_INIT_MODE=sourcing
function zvm_config() {
  ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
  ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
  ZVM_SYSTEM_CLIPBOARD_ENABLED=true
}
[[ -f "${HOMEBREW_PREFIX}/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh" ]] && \
  source "${HOMEBREW_PREFIX}/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"

# direnv
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# nvm/fnm removed 2026-09-15 (standardize on mise). Backup in ~/.config/zsh.bak.*.

# Starship prompt (once-guard, same reason as the instant prompt in .zshrc:
# re-eval would re-wrap zle-keymap-select around itself)
if (( ! ${+_STARSHIP_FULL_SOURCED} )); then
  command -v starship &>/dev/null && eval "$(starship init zsh)"
  _STARSHIP_FULL_SOURCED=1
fi

# zoxide
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# fzf keybindings + completion (CTRL-R history, CTRL-T files, ALT-C dirs).
# TTY-guarded: fzf's integration runs bare `emulate zsh`, which warns
# ("can't change option: zle") and is useless in non-terminal `zsh -i -c`
# contexts (scripts, editors, agents), where there is no prompt to bind to.
if command -v fzf &>/dev/null; then
  [[ -t 0 ]] && source <(fzf --zsh)
  command -v fd &>/dev/null && export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
fi

# VS Code shell integration
[[ "$TERM_PROGRAM" == "vscode" ]] && command -v code &>/dev/null && . "$(code --locate-shell-integration-path zsh)"

# zsh plugins (order matters: autosuggestions first, syntax-highlighting last)
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
[[ -f "${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
  source "${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
bindkey -M viins '^F' autosuggest-accept
[[ -f "${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
  source "${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"