# Devcontainer Quick Start Guide

## Setup Complete ✅

Your devcontainer system is now fully configured with:
- WezTerm multiplexing for fast container connections
- Workspace mounting for full development workflow
- Auto-syncing dotfiles
- Templates for different project types

## Using Devcontainers

### Simplest Approach (Recommended)

For any project, copy the example template and customize:

```bash
# In your project directory
cd ~/my-new-project
mkdir -p .devcontainer
cp ~/.config/.devcontainer/templates/example-project.json .devcontainer/devcontainer.json

# Edit the file and change:
# 1. "name": "my-project" -> your project name
# 2. "runArgs": ["-p", "2222:2222"] -> change port if you have multiple containers
#    (use 2222 for first project, 2223 for second, 2224 for third, etc.)
```

That's it! Now start the container (see step 2 below).

### Language-Specific Templates (Optional)

If you need language-specific features, other templates are available:
- `nodejs-devcontainer.json` - Node.js with optimized node_modules volume
- `python-devcontainer.json` - Python with pip cache
- `basic-devcontainer.json` - Same as example-project.json

### Step-by-Step Workflow

### 1. Create a New Project

### 1. Create a New Project

See "Simplest Approach" above for the quickest way.

Alternative detailed steps:

```bash
# Create project directory
mkdir ~/my-new-project
cd ~/my-new-project

# Copy template
mkdir .devcontainer
cp ~/.config/.devcontainer/templates/example-project.json .devcontainer/devcontainer.json

# Edit and customize name + port
# Change "name": "my-project" to your actual project name
# Change port if needed: "runArgs": ["-p", "2223:2222"]
```

### 2. Start the Container

```bash
cd ~/my-new-project
devcontainer up --workspace-folder .
```

Your project files will be mounted at `/workspace` in the container.

### 3. Connect via WezTerm

**Cmd+P**: Select and connect to a container
1. Press **Cmd+P** in WezTerm
2. Select your container from the fuzzy finder
3. You're now inside the container with full terminal performance!

**Cmd+9**: Switch between workspaces (when you have multiple containers)
1. Press **Cmd+9** to see all active workspaces
2. Select a workspace to switch to it
3. Each container gets its own workspace (e.g., "my-project", "urls")

All your dotfiles (nvim, zsh, etc.) are available inside the container.

### 4. Work on Your Project

Inside the container:
```bash
# Your files are at /workspace
cd /workspace

# Edit with nvim (your config is already there!)
nvim myfile.js

# Install dependencies
npm install  # for Node.js projects
pip install -r requirements.txt  # for Python projects

# Run your app
npm run dev
```

Outside the container (on your Mac):
- Edit files with any editor (VS Code, Sublime, etc.)
- Changes instantly appear in the container
- Use Git, file browsers, etc. normally

### 5. Stop/Restart Containers

```bash
# List running containers
docker ps

# Stop container (files persist on host!)
docker stop <container-name>

# Start existing container
docker start <container-name>

# Remove container (project files safe on host)
docker rm <container-name>

# Rebuild from scratch
devcontainer up --workspace-folder . --remove-existing-container
```

## Available Templates

### example-project.json (Recommended Start)
Generic template for any project. Just change name and port.

### basic-devcontainer.json
Same as example-project.json. Minimal setup with workspace mounting.

### nodejs-devcontainer.json
Includes:
- Node.js LTS
- `node_modules` as named volume (much faster on Mac)
- Auto `npm install` on creation
- Common ports forwarded (3000, 5173, 8080)

### python-devcontainer.json
Includes:
- Python 3.12
- Pip cache as volume
- Auto `pip install -r requirements.txt` on creation
- Common ports forwarded (8000, 5000)

## Multiple Projects Running Simultaneously

You can run up to 10 containers at once (ports 2222-2231).

**Port allocation:**
- Project 1: `"runArgs": ["-p", "2222:2222"]`
- Project 2: `"runArgs": ["-p", "2223:2222"]`
- Project 3: `"runArgs": ["-p", "2224:2222"]`
- etc.

Cmd+P will show all running containers!

## File Syncing Behavior

### What's Mounted
- **Project files**: `/workspace` → your project directory
  - Bidirectional, instant sync
  - Editable from host or container
  - Survives container deletion

### What's Cloned
- **Dotfiles**: `~/.config` → your dotfiles repo
  - One-time clone on create
  - Auto-pulls updates on start
  - Reset when container rebuilt

### What's Cached (if using templates)
- **Dependencies**: `node_modules`, `.cache`, etc.
  - Stored in Docker volumes (fast)
  - Persists across restarts
  - Lost when container removed

## Tips

### Performance on Mac
Use named volumes for large dependency directories:
```json
"mounts": [
  "source=${localWorkspaceFolderBasename}-node_modules,target=/workspace/node_modules,type=volume"
]
```

This is 5-10x faster than mounting from Mac's filesystem.

### Port Forwarding
Add ports your app needs:
```json
"forwardPorts": [3000, 8080, 5432]
```

Access from Mac: `http://localhost:3000`

### Custom Commands
Run commands on container lifecycle:
```json
"postCreateCommand": "npm install && npm run setup",
"postStartCommand": "cd ~/.config && git pull"
```

### Environment Variables
```json
"remoteEnv": {
  "NODE_ENV": "development",
  "DATABASE_URL": "postgresql://localhost/mydb"
}
```

## Workflow Example: Node.js Project

```bash
# 1. Create project
mkdir ~/my-app && cd ~/my-app
npm init -y

# 2. Setup devcontainer
mkdir .devcontainer
cp ~/.config/.devcontainer/templates/nodejs-devcontainer.json .devcontainer/devcontainer.json

# Edit .devcontainer/devcontainer.json:
# - Change name to "my-app"
# - Keep port 2222 (or use 2223 if 2222 taken)

# 3. Start container
devcontainer up --workspace-folder .

# 4. Connect in WezTerm
# Press Cmd+P, select "my-app"

# 5. Inside container:
cd /workspace
npm install express
nvim index.js  # Your nvim config works!
node index.js

# 6. On Mac:
# Open http://localhost:3000 in browser
# Edit files with VS Code if you want
# Git commit/push works normally
```

## Troubleshooting

### Container not in Cmd+P menu
```bash
docker ps  # Verify port 2222 is exposed
# Restart WezTerm
```

### Files not appearing in /workspace
Check that `workspaceMount` is in devcontainer.json:
```json
"workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind"
```

### Permission errors
The container runs as `vscode` user (UID 1000). If you get permission errors:
```bash
# Inside container
sudo chown -R vscode:vscode /workspace
```

### Slow performance (node_modules)
Use volume mounts instead of bind mounts for dependencies (see templates).

## Next Steps

- Create your first real project using a template
- Customize the base image if you need additional tools
- Add more templates for other languages/frameworks
- Check out `~/.config/.devcontainer/README.md` for advanced topics

Happy containerized development! 🚀
