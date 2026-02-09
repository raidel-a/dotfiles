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

The Makefile automatically uses `gh` CLI for authentication:

```bash
# First, ensure gh CLI has write:packages scope
gh auth refresh -h github.com -s write:packages

# Then push
make push
```

The push command will automatically use `gh auth token` - no need to manually set environment variables.

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

A dedicated SSH key is required for WezTerm to connect to containers. Generate it with:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_devcontainer -N ""
```

This key is automatically added to containers' authorized_keys via the install.sh script.

**Note:** The key should already be generated if you've completed the initial setup.

## Workflow

### Initial Setup (One Time)

1. Generate SSH key: `ssh-keygen -t ed25519 -f ~/.ssh/id_devcontainer -N ""`
2. Build base image: `cd ~/.config/.devcontainer && make build`
3. Push to GHCR: `gh auth refresh -h github.com -s write:packages && make push`

### For Each Project

1. Create `.devcontainer/devcontainer.json` in your project (see example above)
2. Start container: `devcontainer up --workspace-folder .`
3. Press **Cmd+P** in WezTerm
4. Select your container from the list
5. Work with full Neovim performance inside the container

### Updating the Base Image

When you update your dotfiles and want new containers to use the latest config:

```bash
cd ~/.config/.devcontainer
make build
make push
```

Existing containers can pull updates automatically via the `postStartCommand`.

## Notes

- The container clones dotfiles to `~/.config` (matching macOS structure)
- SSH agent forwarding is enabled for Git operations
- Dotfiles are auto-updated on container start via `postStartCommand`
- Timezone is set to America/Los_Angeles (change in devcontainer.json if needed)
- The `runArgs` with `-p 2222:2222` is **required** for SSH port exposure

## Troubleshooting

### Container not appearing in Cmd+P menu
- Verify port 2222 is exposed: `docker ps`
- Check if runArgs includes `-p 2222:2222` in devcontainer.json
- Restart WezTerm to reload the config

### SSH connection fails
- Ensure `~/.ssh/id_devcontainer` exists with correct permissions (600)
- Verify the public key is in the container: `docker exec <container-id> cat /home/vscode/.ssh/authorized_keys`
- Test direct SSH: `ssh -p 2222 -i ~/.ssh/id_devcontainer vscode@127.0.0.1`

### Multiple containers conflict
Each container needs a unique host port. Use different ports like:
- Container 1: `"runArgs": ["-p", "2222:2222"]`
- Container 2: `"runArgs": ["-p", "2223:2222"]`
- Container 3: `"runArgs": ["-p", "2224:2222"]`

WezTerm will automatically discover containers on any port.
