# Devcontainer Base Image

Prebuilt base image for devcontainers with WezTerm multiplexing support.

Inspired by [Simon Ho's multiplexed devcontainer setup](https://www.simonho.ca/posts/multiplex-devcontainers).

## What's Inside

- Ubuntu base from Microsoft's devcontainer images
- WezTerm nightly build
- Homebrew for Linux
- Your complete dotfiles setup (nvim, zsh, wezterm configs)
- SSH server for WezTerm multiplexing

## Building and Publishing

### Prerequisites

```bash
npm install -g @devcontainers/cli
```

### Build the image

```bash
cd .devcontainer
make build
```

### Push to GitHub Container Registry

```bash
export GH_TOKEN=<your-github-token>
make push
```

Make sure your token has `write:packages` permission.

### View tags

```bash
make tags
```

## Using in Projects

In your project's `.devcontainer/devcontainer.json`:

```json
{
  "name": "my-project",
  "image": "ghcr.io/raidel-a/devcontainer-base:latest",
  "features": {
    "ghcr.io/devcontainers/features/sshd:1": {}
  },
  "runArgs": ["-p", "2222:2222"]
}
```

**Important:** The `runArgs` with `-p 2222:2222` is required to expose the SSH port for WezTerm multiplexing to work.

## Connecting via WezTerm

Once the container is running, use the WezTerm multiplexing keybind (Cmd+P) to:
1. Discover running containers
2. Select the container you want to connect to
3. Connect seamlessly with full local WezTerm performance

See the WezTerm config in `../wezterm/utils/devcontainer.lua` for implementation details.

## SSH Key Setup

Generate a dedicated SSH key for devcontainers:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_devcontainer -N ""
```

This key will be used by WezTerm to connect to containers.

## Workflow

1. Build and push the base image (do this once, or when you update dotfiles)
2. Create project devcontainers using this base image
3. Start the devcontainer in VS Code or via `devcontainer up`
4. Press Cmd+P in WezTerm to connect to the running container
5. Work with full Neovim performance inside the container

## Notes

- The container clones dotfiles to `~/.config` (matching macOS structure)
- SSH agent forwarding is enabled for Git operations
- Dotfiles are auto-updated on container start via `postStartCommand`
- Timezone is set to America/Los_Angeles (change in devcontainer.json if needed)
