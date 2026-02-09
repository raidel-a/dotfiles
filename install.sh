#!/bin/bash
set -e

echo "Setting up dotfiles for Linux container..."

# Ensure we're in the dotfiles directory
cd "$(dirname "$0")"
DOTFILES_DIR="$(pwd)"

# Add Homebrew to PATH for this script
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Install Brewfile packages (excluding casks which don't work on Linux)
echo "Installing Homebrew packages..."
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
	# Filter out cask lines since they don't work on Linux
	grep -v "^cask" "$DOTFILES_DIR/Brewfile" >/tmp/Brewfile.linux || true
	brew bundle --file=/tmp/Brewfile.linux --no-lock || echo "Some packages may have failed, continuing..."
	rm /tmp/Brewfile.linux
fi

# Create symlinks for zsh config
echo "Creating zsh symlinks..."
ln -sf "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/zsh/zshenv" "$HOME/.zshenv"

# WezTerm config is already in .config, no need to symlink
echo "WezTerm config available at ~/.config/wezterm"

# Neovim config is already in .config, no need to symlink
echo "Neovim config available at ~/.config/nvim"

# Install fonts if on Linux (for potential GUI usage)
if [ -d "$DOTFILES_DIR/Fonts" ]; then
	echo "Setting up fonts..."
	mkdir -p "$HOME/.local/share/fonts"

	# Check if MapleMonoNerdFont needs to be downloaded
	if [ ! -d "$DOTFILES_DIR/Fonts/MapleMonoNerdFont" ]; then
		FONT_LINK="https://github.com/raidel-a/dotfiles/releases/download/v1.0.0/MapleMonoNerdFont.zip"
		FONT_NAME="MapleMonoNerdFont.zip"

		echo "Downloading fonts from $FONT_LINK..."
		wget -q "$FONT_LINK" -O "/tmp/$FONT_NAME" || echo "Font download failed, skipping..."

		if [ -f "/tmp/$FONT_NAME" ]; then
			echo "Unzipping fonts..."
			unzip -q "/tmp/$FONT_NAME" -d "$DOTFILES_DIR/Fonts" || echo "Font unzip failed, skipping..."
			rm "/tmp/$FONT_NAME"
		fi
	fi

	# Copy fonts to user directory
	if [ -d "$DOTFILES_DIR/Fonts" ]; then
		cp -r "$DOTFILES_DIR/Fonts/"* "$HOME/.local/share/fonts/" 2>/dev/null || true
		fc-cache -fv >/dev/null 2>&1 || echo "Font cache update failed, skipping..."
	fi
fi

# Source zsh to set up environment
echo "Sourcing zsh config..."
if [ -f "$HOME/.zshrc" ]; then
	# We can't fully source it in bash, but we can validate it exists
	echo "zshrc linked successfully at $HOME/.zshrc"
fi

# Setup starship if available
if command -v starship >/dev/null 2>&1; then
	echo "Starship installed and available"
fi

# Setup fzf if available
if command -v fzf >/dev/null 2>&1; then
	echo "fzf installed and available"
fi

# Setup direnv if available
if command -v direnv >/dev/null 2>&1; then
	echo "direnv installed and available"
fi

# Setup SSH authorized_keys for WezTerm multiplexing
echo "Setting up SSH access for WezTerm multiplexing..."
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Add the devcontainer SSH public key
DEVCONTAINER_PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMkpCgDd+jgEHkjzeMsoVe7C482W8Udqt0NqyplSXYsC devcontainer-multiplexing"

if [ -f "$HOME/.ssh/authorized_keys" ]; then
	# Check if key already exists
	if ! grep -q "$DEVCONTAINER_PUBKEY" "$HOME/.ssh/authorized_keys"; then
		echo "$DEVCONTAINER_PUBKEY" >>"$HOME/.ssh/authorized_keys"
		echo "Added devcontainer SSH key to authorized_keys"
	else
		echo "Devcontainer SSH key already in authorized_keys"
	fi
else
	echo "$DEVCONTAINER_PUBKEY" >"$HOME/.ssh/authorized_keys"
	echo "Created authorized_keys with devcontainer SSH key"
fi

chmod 600 "$HOME/.ssh/authorized_keys"

echo ""
echo "Dotfiles setup complete!"
echo "Configuration location: $DOTFILES_DIR"
echo ""
echo "To finish setup, restart your shell or run: exec zsh"
