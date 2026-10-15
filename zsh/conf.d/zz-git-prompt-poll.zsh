# conf.d/zz-git-prompt-poll.zsh
#
# Idle git-status refresh for starship.
#
# Why: starship only renders on precmd/preexec/keymap-select, so the prompt's
# git_status goes stale while you sit at it and something else changes the repo
# (another pane, an agent, a background fetch). This polls `git status` on a
# timer and calls `zle reset-prompt` when the status actually changed.
#
# Cost: one `git status --porcelain` per interval. Measured on this machine:
# ~20ms in a ~2k-file tree, ~100-220ms in a 2.4k-tracked-file tree with many
# untracked dirs. Raise GIT_PROMPT_POLL_INTERVAL, or set it to 0 to disable.
#
# Redraw policy: you already get a fresh render from precmd after every command
# you run, so this only redraws for changes made while idle. precmd marks the
# snapshot stale; the next poll silently re-baselines instead of redrawing. The
# one gap: a change made by another process within one interval of your own last
# command shows up on your next command, not immediately.

[[ -o interactive ]] || return 0
zmodload zsh/sched 2>/dev/null || return 0

typeset -g GIT_PROMPT_POLL_INTERVAL=${GIT_PROMPT_POLL_INTERVAL:-10}
(( GIT_PROMPT_POLL_INTERVAL > 0 )) || return 0

typeset -g _git_poll_snapshot=''
typeset -g _git_poll_stale=1
typeset -g _git_poll_refreshes=0   # debug counter: idle redraws performed

_git_prompt_poll_snapshot() {
  # GIT_OPTIONAL_LOCKS=0: never take the index lock or refresh the index from a
  # prompt poll. Without this, a poller can write .git/index just to render.
  GIT_OPTIONAL_LOCKS=0 command git status --porcelain=v1 --branch 2>/dev/null
}

# precmd: the prompt starship is about to draw reflects the repo right now, so
# the next poll should re-baseline rather than redraw. Deliberately no git call
# here - that would add a second status run to every prompt.
_git_prompt_poll_mark_stale() { _git_poll_stale=1 }
autoload -Uz add-zsh-hook
add-zsh-hook precmd _git_prompt_poll_mark_stale

_git_prompt_poll() {
  # Capture $? before anything else: `emulate` resets it to 0, which would
  # otherwise make a later `echo $?` report 0 instead of the user's last status.
  local last_status=$?
  emulate -L zsh
  local snapshot
  snapshot=$(_git_prompt_poll_snapshot)

  if (( _git_poll_stale )); then
    _git_poll_snapshot=$snapshot
    _git_poll_stale=0
  elif [[ $snapshot != $_git_poll_snapshot ]]; then
    _git_poll_snapshot=$snapshot
    (( _git_poll_refreshes++ ))
    # ZLE is necessarily active here: sched only runs while the shell waits at
    # the prompt. Suppress stderr so a widget error can never corrupt the line.
    zle reset-prompt 2>/dev/null
  fi

  sched +${GIT_PROMPT_POLL_INTERVAL} _git_prompt_poll
  return $last_status
}

# Schedule rather than call: the first poll happens after one interval, so a
# slow `git status` never delays shell startup.
sched +${GIT_PROMPT_POLL_INTERVAL} _git_prompt_poll
