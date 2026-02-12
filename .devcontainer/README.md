# Devcontainer Base Image

Prebuilt base image for devcontainers with WezTerm multiplexing support and full development workflow.

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

### Two Approaches

**Option A: Quick Copy (Simplest)**

Copy the example template and customize:

```bash
# In your project directory
mkdir -p .devcontainer
cp ~/.config/.devcontainer/templates/example-project.json .devcontainer/devcontainer.json

# Edit and change:
# 1. "name": "my-project" -> your project name
# 2. "runArgs": ["-p", "2222:2222"] -> unique port (2222, 2223, 2224, etc.)
# 3. "TZ": "America/New_York" -> your timezone (optional)
```

**Option B: Language-Specific Templates**

Templates are available in `.devcontainer/templates/`:

- `example-project.json` - Generic template (start here)
- `basic-devcontainer.json` - Minimal setup with workspace mounting
- `nodejs-devcontainer.json` - Node.js with npm/yarn/pnpm support
- `python-devcontainer.json` - Python with pip and virtual environment

### Basic Configuration Example

In your project's `.devcontainer/devcontainer.json`:

```json
{
  "name": "my-project",
  "image": "ghcr.io/raidel-a/devcontainer-base:latest",
  
  // Mount your project files
  "workspaceFolder": "/workspace",
  "workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind",
  
  // SSH server for WezTerm multiplexing
  "features": {
    "ghcr.io/devcontainers/features/sshd:1": {}
  },
  
  // SSH port mapping (CHANGE THIS for each project: 2222, 2223, 2224, etc.)
  "runArgs": ["-p", "2222:2222"],
  
  // SSH agent forwarding
  "mounts": [
    "source=${localEnv:SSH_AUTH_SOCK},target=/home/vscode/.ssh/ssh-agent,type=bind"
  ],
  
  "remoteEnv": {
    "SSH_AUTH_SOCK": "/home/vscode/.ssh/ssh-agent"
  },
  
  "remoteUser": "vscode"
}
```

**Important:** The `runArgs` with `-p 2222:2222` is required to expose the SSH port for WezTerm multiplexing to work.

### Development Workflow

With workspace mounting, your project files are:
- **Live synced** between host and container
- **Editable** from either host or container
- **Persisted** on the host (not lost when container is deleted)

Example:
1. Edit `file.js` on your Mac with any editor
2. Changes instantly appear in the container at `/workspace/<project-name>/file.js`
3. Run tests/build inside the container
4. All changes persist on your Mac

Note: The workspace is mounted at `/workspace/<project-name>` where `<project-name>` is your project directory name (e.g., `/workspace/urls` for a project in `~/Desktop/urls`).

### Language-Specific Optimizations

#### Node.js Projects

Use a named volume for `node_modules` to improve performance on Mac:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/sshd:1": {},
    "ghcr.io/devcontainers/features/node:1": {
      "version": "lts"
    }
  },
  "mounts": [
    "source=${localEnv:SSH_AUTH_SOCK},target=/home/vscode/.ssh/ssh-agent,type=bind",
    // Store node_modules in a volume (much faster than bind mount)
    "source=${localWorkspaceFolderBasename}-node_modules,target=/workspace/${localWorkspaceFolderBasename}/node_modules,type=volume"
  ],
  "postCreateCommand": "npm install",
  "forwardPorts": [3000, 5173, 8080]
}
```

#### Python Projects

```json
{
  "features": {
    "ghcr.io/devcontainers/features/sshd:1": {},
    "ghcr.io/devcontainers/features/python:1": {
      "version": "3.12"
    }
  },
  "mounts": [
    "source=${localEnv:SSH_AUTH_SOCK},target=/home/vscode/.ssh/ssh-agent,type=bind",
    // Cache pip packages
    "source=${localWorkspaceFolderBasename}-pip-cache,target=/home/vscode/.cache/pip,type=volume"
  ],
  "postCreateCommand": "pip install -r requirements.txt",
  "forwardPorts": [8000, 5000]
}
```

### Multiple Containers

WezTerm is pre-configured with SSH domains for ports 2222-2231, allowing up to **10 concurrent containers**. 

If you need multiple containers running simultaneously, assign different host ports:

```json
// Container 1
"runArgs": ["-p", "2222:2222"]

// Container 2
"runArgs": ["-p", "2223:2222"]

// Container 3
"runArgs": ["-p", "2224:2222"]
```

The Cmd+P selector will automatically discover all running containers on any of these ports.

## Connecting via WezTerm

Once the container is running, use the WezTerm multiplexing keybind (Cmd+P) to:
1. Discover running containers
2. Select the container you want to connect to
3. Connect via **true WezTerm multiplexing** (not plain SSH)

This provides significantly better performance than regular SSH - no redraw lag, smooth scrolling, and local terminal responsiveness.

Each container opens in its own named workspace. When you exit from all tabs in a workspace, the window automatically closes.

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

1. Copy a template from `.devcontainer/templates/` to your project
2. Customize the `name` and port number (templates use directory name automatically)
3. Start container: `devcontainer up --workspace-folder .`
4. Press **Cmd+P** in WezTerm
5. Select your container from the list
6. Work with full Neovim performance inside the container
7. Your files at `/workspace/<project-name>` are synced with your host project directory

### Starting/Stopping Containers

```bash
# Start container
cd ~/my-project
devcontainer up --workspace-folder .

# Stop container (files persist on host)
docker stop <container-name>

# Restart existing container
docker start <container-name>

# Rebuild container (e.g., after updating base image)
devcontainer up --workspace-folder . --remove-existing-container
```

### Updating the Base Image

When you update your dotfiles and want new containers to use the latest config:

```bash
cd ~/.config/.devcontainer
make build
make push
```

Existing containers can pull dotfile updates automatically via the `postStartCommand`.

## File Syncing Explained

### What Gets Synced

1. **Project files** (via workspace mount):
   - Source: Your host project directory
   - Target: `/workspace/<project-name>` in container (e.g., `/workspace/urls`)
   - Sync: Bidirectional, live (instant)
   - Persists: On host, survives container deletion

2. **Dotfiles** (via git clone on container creation):
   - Source: Your dotfiles repo
   - Target: `~/.config` in container  
   - Sync: One-time on create, auto-pull on start
   - Persists: In container only (reset on rebuild)

3. **Dependencies** (optional volumes):
   - `node_modules`, `.cache`, etc.
   - Stored in Docker volumes for performance
   - Persists: Across container restarts (not rebuilds)

### Performance Tips

- **Bind mounts** (project files): Good for source code, slower for dependencies
- **Named volumes** (node_modules): Much faster for large dependency trees on Mac
- **tmpfs**: Fastest, but data lost on container stop (rarely used)

## Notes

- The container clones dotfiles to `~/.config` (matching macOS structure)
- SSH agent forwarding is enabled for Git operations
- Dotfiles are auto-updated on container start via `postStartCommand`
- Timezone is set to America/Los_Angeles (change in devcontainer.json if needed)
- The `runArgs` with `-p 2222:2222` is **required** for SSH port exposure
- **WezTerm Multiplexing:** Connections use true WezTerm multiplexing (not plain SSH) for optimal performance
- **Pre-allocated Domains:** SSH domains for ports 2222-2231 are pre-configured (10 concurrent containers max)
- **Workspace Auto-close:** Empty workspace windows automatically close when you exit all tabs

## Troubleshooting

### Container not appearing in Cmd+P menu
- Verify port 2222 is exposed: `docker ps`
- Check if runArgs includes `-p 2222:2222` in devcontainer.json
- Restart WezTerm to reload the config

### SSH connection fails
- Ensure `~/.ssh/id_devcontainer` exists with correct permissions (600)
- Verify the public key is in the container: `docker exec <container-id> cat /home/vscode/.ssh/authorized_keys`
- Test direct SSH: `ssh -p 2222 -i ~/.ssh/id_devcontainer vscode@127.0.0.1`

### Files not appearing in /workspace/<project-name>
- Check that `workspaceMount` is configured in devcontainer.json
- Verify the mount: `docker inspect <container-id> | grep Mounts -A 20`
- Ensure container was created after adding the mount (rebuild if needed)
- Check you're looking in the right path: `/workspace/<project-name>` not just `/workspace`

### Multiple containers conflict
Each container needs a unique host port, but the container's internal port is always 2222.

**Port Allocation:**
- WezTerm pre-allocates SSH domains for ports 2222-2231 (10 slots)
- Each container should use a unique host port in this range
- Example configurations:
  - Container 1: `"runArgs": ["-p", "2222:2222"]`
  - Container 2: `"runArgs": ["-p", "2223:2222"]`
  - Container 3: `"runArgs": ["-p", "2224:2222"]`

The selector will automatically detect containers on any of these ports and connect using WezTerm multiplexing.

### node_modules performance issues on Mac
Use a named volume instead of bind mount:
```json
"mounts": [
  "source=${localWorkspaceFolderBasename}-node_modules,target=/workspace/${localWorkspaceFolderBasename}/node_modules,type=volume"
]
```

This stores node_modules in a Docker volume (Linux filesystem) instead of mounting from Mac (slower due to filesystem translation).

