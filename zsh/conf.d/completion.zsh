# Completion configurations

# Docker completions
fpath=(/Users/rai/.docker/completions $fpath)

# Set up completion dump file with daily checking for performance
# This prevents multiple .zcompdump files from accumulating
autoload -Uz compinit
ZSH_COMPDUMP="${ZDOTDIR}/.zcompdump"

# Only regenerate compdump once per day
if [[ -n ${ZSH_COMPDUMP}(#qNmh+24) ]]; then
  compinit -d "${ZSH_COMPDUMP}"
  # Clean up old dump files
  /bin/rm -f "${ZSH_COMPDUMP}.zwc" ${ZDOTDIR}/.zcompdump.*(N)
else
  compinit -C -d "${ZSH_COMPDUMP}"
fi

# Completion UX: case-insensitive matching, menu selection, colors
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Bun completions
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# Angular CLI completion (lazy-loaded: `ng completion script` forks node)
if command -v ng &>/dev/null; then
  ng() {
    unfunction ng
    source <(command ng completion script)
    command ng "$@"
  }
fi

# ngrok completions (lazy-loaded)
if command -v ngrok &>/dev/null; then
  ngrok() {
    unfunction ngrok
    eval "$(command ngrok completion)"
    command ngrok "$@"
  }
fi

# OpenCode completions
_opencode_yargs_completions()
{
  local reply
  local si=$IFS
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" opencode --get-yargs-completions "${words[@]}"))
  IFS=$si
  if [[ ${#reply} -gt 0 ]]; then
    _describe 'values' reply
  else
    _default
  fi
}
if [[ "'${zsh_eval_context[-1]}" == "loadautofunc" ]]; then
  _opencode_yargs_completions "$@"
else
  compdef _opencode_yargs_completions opencode
fi
###-end-opencode-completions-###
