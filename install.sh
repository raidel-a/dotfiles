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

	# Do NOT pass --no-lock. Homebrew 7 removed the flag and `brew bundle`
	# rejects the whole invocation with a usage error, so this step installed
	# nothing at all - and the old `|| echo "...continuing..."` made that
	# failure read like success. Partial failure is still expected on Linux
	# (some formulae are macOS-only), so this reports instead of aborting
	# under the `set -e` above, but it no longer claims to have continued.
	if brew bundle --file=/tmp/Brewfile.linux; then
		echo "Homebrew packages installed"
	else
		echo "WARNING: brew bundle exited non-zero - some packages may be missing" >&2
	fi

	rm /tmp/Brewfile.linux
fi

# Create symlinks for zsh config.
# The dotfiles are tracked as dotfiles (zsh/.zshenv), so the link targets must
# include the leading dot. ~/.zshenv is the essential one: zsh reads it from
# $HOME before ZDOTDIR is set, and it is what sets ZDOTDIR to $DOTFILES_DIR/zsh.
# ~/.zshrc is vestigial for the same reason (zsh reads $ZDOTDIR/.zshrc) but is
# kept so shells started without the ZDOTDIR export still find a config.
echo "Creating zsh symlinks..."
ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/zsh/.zshenv" "$HOME/.zshenv"

# Sanity-check the links resolved, rather than reporting success blindly.
for link in "$HOME/.zshrc" "$HOME/.zshenv"; do
	if [ -e "$link" ]; then
		echo "  linked $link -> $(readlink "$link")"
	else
		echo "  WARNING: $link is a broken symlink" >&2
	fi
done

# WezTerm config is already in .config, no need to symlink
echo "WezTerm config available at ~/.config/wezterm"

# Neovim config is already in .config, no need to symlink
echo "Neovim config available at ~/.config/nvim"

# Install fonts if on Linux (for potential GUI usage)
if [ -d "$DOTFILES_DIR/Fonts" ]; then
	echo "Setting up fonts..."
	FONT_DIR="$HOME/.local/share/fonts"
	mkdir -p "$FONT_DIR"

	# Both archives are release assets rather than tracked files: they are
	# multi-megabyte binaries and the release host already serves
	# MapleMonoNF-CN. Cached under Fonts/ on first run (both paths ignored).
	RELEASE_URL="https://github.com/raidel-a/dotfiles/releases/download/v1.1.0"

	# fetch_archive <zip-name>: extract into Fonts/<name-without-.zip>/ if
	# absent. Prefers a copy already sitting in Fonts/ - which is what the
	# move to release assets leaves behind - over re-downloading.
	fetch_archive() {
		zip_name="$1"
		cache_dir="$DOTFILES_DIR/Fonts/${zip_name%.zip}"
		zip_path="$DOTFILES_DIR/Fonts/$zip_name"
		downloaded=""

		if [ -d "$cache_dir" ]; then
			return 0
		fi

		if [ -f "$zip_path" ]; then
			echo "Using local Fonts/$zip_name"
		else
			zip_path="/tmp/$zip_name"
			downloaded="yes"
			echo "Downloading $zip_name..."
			if ! wget -q "$RELEASE_URL/$zip_name" -O "$zip_path"; then
				echo "  $zip_name download failed, skipping..."
				return 0
			fi
		fi

		if unzip -q -o "$zip_path" -d "$cache_dir"; then
			echo "  extracted to $cache_dir"
		else
			echo "  $zip_name unzip failed, skipping..."
		fi

		if [ -n "$downloaded" ]; then
			rm -f "$zip_path"
		fi
		return 0
	}

	fetch_archive "MapleMonoNF-CN.zip"
	fetch_archive "SymbolsNerdFont.zip"

	# Copy font binaries only. The caches above also hold the zips and macOS
	# resource-fork junk (__MACOSX/._*.ttf), which are themselves .ttf names
	# and must not be installed as fonts.
	find "$DOTFILES_DIR/Fonts" -type f \
		\( -iname '*.ttf' -o -iname '*.otf' -o -iname '*.ttc' \) \
		-not -path '*__MACOSX*' \
		-exec cp -f {} "$FONT_DIR/" \; 2>/dev/null

	fc-cache -fv >/dev/null 2>&1 || echo "Font cache update failed, skipping..."
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

# Install the secret-scanning pre-commit hook. .git/hooks is not tracked, so a
# fresh clone has no protection until this runs.
if [ -f "$DOTFILES_DIR/git/hooks/pre-commit" ] && [ -d "$DOTFILES_DIR/.git/hooks" ]; then
	echo "Installing pre-commit secret scan..."
	install -m 755 "$DOTFILES_DIR/git/hooks/pre-commit" "$DOTFILES_DIR/.git/hooks/pre-commit"
fi

echo ""
echo "Dotfiles setup complete!"
echo "Configuration location: $DOTFILES_DIR"
echo ""
echo "To finish setup, restart your shell or run: exec zsh"
