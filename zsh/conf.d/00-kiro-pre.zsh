# Kiro CLI pre-initialization (moved from .zshrc by user, 2026-09-12)
# Canonical location for Kiro pre block. If the Kiro installer re-adds
# pre/post blocks to .zshrc/.zprofile, remove them there and keep them here
# so .zshrc stays a pure conf.d loader.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"
