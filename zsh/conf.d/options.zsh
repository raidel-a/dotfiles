# Zsh options and behavior configurations

# History options
setopt EXTENDED_HISTORY       # Record timestamp of command
setopt HIST_VERIFY           # Show command with history expansion before running it
setopt HIST_IGNORE_DUPS      # Don't record duplicated commands
setopt HIST_IGNORE_SPACE     # Don't record commands starting with space

# Directory navigation
setopt AUTO_CD              # Just type directory name to cd
setopt AUTO_PUSHD          # Make cd push the old directory onto the stack 