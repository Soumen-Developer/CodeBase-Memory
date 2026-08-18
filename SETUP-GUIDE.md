# Codebase-Memory-MCP — Complete Setup Guide

**For users who want to get started quickly — no Docker, no complex config, just works.**

---

## What Is This?

Codebase-Memory-MCP is a **code intelligence engine** that:
- **Indexes your entire codebase in seconds** (even huge ones like Linux kernel in ~3 minutes)
- **Lets AI agents understand your code** through 15 powerful tools (search, trace calls, find dead code, architecture view, etc.)
- **Shows a beautiful 3D graph** of your code at `http://localhost:9749`
- **Runs 100% locally** — your code never leaves your machine
- **Installs in one command** and works with 43+ AI coding agents (Cursor, Copilot, Windsurf, Claude Code, etc.)

---

## Quick Start (Recommended)

### macOS / Linux — One Command

```bash
curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
# 1. Download the installer
Invoke-WebRequest -Uri https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.ps1 -OutFile install.ps1

# 2. (Optional) Inspect the script
notepad install.ps1

# 3. Unblock the downloaded file
Unblock-File .\install.ps1

# 4. Run it
.\install.ps1
```

> **If you get a script execution policy error:** Run `Set-ExecutionPolicy -Scope Process Bypass` first, or use `PowerShell -ExecutionPolicy Bypass -File .\install.ps1`.

---

## What the Installer Does

1. **Downloads** the right binary for your OS/architecture (macOS arm64/amd64, Linux arm64/amd64, Windows amd64)
2. **Installs** it to `~/.local/bin/codebase-memory-mcp`
3. **Detects your AI agents** (Cursor, VS Code Copilot, Windsurf, Claude Code, Zed, etc.) and configures them automatically
4. **Starts the background daemon** with the graph UI at `http://localhost:9749`

**That's it. Restart your AI agent and say "Index this project."**

---

## After Installation — First Steps

### 1. Restart Your AI Agent

Close and reopen Cursor, VS Code, Windsurf, Claude Code, or whichever agent you use.

### 2. Index Your Project

In your AI agent's chat, say:
> **"Index this project"**

The agent will run the indexer. For a typical repo this takes **seconds**. For huge repos (millions of lines) it takes **minutes**.

### 3. Start Using It

Once indexed, you can ask your agent things like:
- *"Find all functions that call `authenticate_user()`"*
- *"Show me the architecture of this codebase"*
- *"What HTTP routes does this API have?"*
- *"Find dead code in this project"*
- *"Trace the call chain from `main()` to `process_payment()`"*

### 4. Open the Graph UI

Open your browser to **`http://localhost:9749`** — you'll see a 3D interactive graph of your codebase:
- **Nodes** = functions, classes, files, modules
- **Edges** = calls, imports, inheritance, HTTP routes
- **Click, drag, zoom, filter** — explore visually

---

## Alternative: Manual Install

If you prefer not to pipe to bash, or the one-liner doesn't work:

### 1. Download the Release

Go to [Latest Release](https://github.com/DeusData/codebase-memory-mcp/releases/latest) and download:
- **macOS/Linux:** `codebase-memory-mcp-<os>-<arch>.tar.gz`
- **Windows:** `codebase-memory-mcp-windows-amd64.zip`

### 2. Extract & Run Installer

**macOS / Linux:**
```bash
tar xzf codebase-memory-mcp-*.tar.gz
./install.sh
```

**Windows (PowerShell):**
```powershell
Expand-Archive codebase-memory-mcp-windows-amd64.zip -DestinationPath .
.\install.ps1
```

### 3. Custom Install Location (Optional)

```bash
# Custom directory
./install.sh --dir /path/to/custom/bin

# Binary only (no agent config)
./install.sh --skip-config
```

---

## Using the Daemon (Background Service)

The installer starts a **permanent background daemon** that:
- Serves the graph UI at `http://localhost:9749`
- Handles MCP requests from your AI agents
- Survives restarts and idle periods

### Daemon Commands

```bash
# Check status
codebase-memory-mcp daemon status

# Stop the daemon
codebase-memory-mcp daemon stop

# Start the daemon (if stopped)
codebase-memory-mcp daemon start

# Restart (useful after config changes)
codebase-memory-mcp daemon restart
```

### Change the UI Port

```bash
# Set custom port (default: 9749)
codebase-memory-mcp config set ui_port 8080

# Restart to apply
codebase-memory-mcp daemon restart
```

---

## Docker (Alternative — For Containerized Environments)

If you prefer Docker or need to run in a container:

### Quick Start with Docker Compose

```bash
# Clone the repo
git clone https://github.com/DeusData/codebase-memory-mcp.git
cd codebase-memory-mcp

# Start daemon + UI
docker compose up -d cbm-daemon

# UI available at http://localhost:9749
```

### Run One-Off CLI Commands

```bash
# Index a workspace
docker compose run --rm cbm-cli index /workspace

# Check version
docker compose run --rm cbm-cli --version

# Any other CLI command
docker compose run --rm cbm-cli --help
```

### Manual Docker Build & Run

```bash
# Build image
docker build -t codebase-memory-mcp .

# Run daemon
docker run -d --name cbm \
  -p 9749:9749 \
  -v cbm-runtime:/run/cbm \
  -v cbm-cache:/root/.cache/codebase-memory-mcp \
  -v $(pwd):/workspace \
  codebase-memory-mcp
```

**Note:** The native install (above) is faster, simpler, and recommended for most users. Docker is only needed for containerized CI/CD or isolated environments.

---

## Supported AI Agents (Auto-Configured)

The installer detects and configures these automatically:

| Agent | Config Method |
|-------|---------------|
| **Cursor** | `.cursor/mcp.json` |
| **VS Code (Copilot)** | `.vscode/mcp.json` |
| **Windsurf** | `~/.codeium/windsurf/mcp_config.json` |
| **Claude Code** | `~/.claude/mcp.json` |
| **Zed** | `~/.config/zed/settings.json` |
| **Continue** | `~/.continue/config.json` |
| **Sourcegraph Cody** | `~/.cody/mcp.json` |
| **And 35+ more...** | See [Multi-Agent Support](README.md#multi-agent-support) |

**If your agent isn't auto-configured:** Add this to your agent's MCP config:
```json
{
  "mcpServers": {
    "codebase-memory-mcp": {
      "command": "codebase-memory-mcp",
      "args": ["mcp"]
    }
  }
}
```

---

## Common Tasks

### Re-index After Big Changes

```bash
# In your project root
codebase-memory-mcp index .
```

### Index a Different Project

```bash
codebase-memory-mcp index /path/to/other/project
```

### Check What's Indexed

```bash
codebase-memory-mcp list-projects
```

### Remove a Project from Index

```bash
codebase-memory-mcp delete-project <project-name>
```

### View Daemon Logs

```bash
codebase-memory-mcp daemon logs
```

---

## Troubleshooting

### "Command not found" after install

**Fix:** Add `~/.local/bin` to your PATH:
```bash
# Add to ~/.bashrc, ~/.zshrc, or ~/.config/fish/config.fish
export PATH="$HOME/.local/bin:$PATH"

# Then reload shell
source ~/.bashrc  # or ~/.zshrc
```

### Port 9749 already in use

**Fix:** Change the port:
```bash
codebase-memory-mcp config set ui_port 8080
codebase-memory-mcp daemon restart
```

### UI not loading at localhost:9749

1. Check daemon is running: `codebase-memory-mcp daemon status`
2. Check logs: `codebase-memory-mcp daemon logs`
3. Try restarting: `codebase-memory-mcp daemon restart`

### Antivirus flags the binary (Windows)

**This is a known false positive** (Microsoft Defender: `Trojan:Script/Wacatac.B!ml`).
- 61+ of ~62 VirusTotal engines return clean
- Same detection hits `gh`, `llama.cpp`, Godot, Microsoft's own Go toolchain
- **Solution:** Add exclusion for `~/.local/bin/codebase-memory-mcp.exe` or verify checksums from the [release page](https://github.com/DeusData/codebase-memory-mcp/releases/latest)

### Agent doesn't see the tools

1. Restart the agent completely (close + reopen)
2. Check agent's MCP config has `codebase-memory-mcp` entry
3. Run `codebase-memory-mcp mcp` manually — should output JSON-RPC
4. Check daemon: `codebase-memory-mcp daemon status`

---

## Uninstall

```bash
# Stop daemon
codebase-memory-mcp daemon stop

# Remove binary
rm ~/.local/bin/codebase-memory-mcp

# Remove cache & config (optional)
rm -rf ~/.cache/codebase-memory-mcp
rm -rf ~/.config/codebase-memory-mcp
```

---

## Getting Help

- **Documentation:** [README.md](README.md) — full reference
- **Issues:** [GitHub Issues](https://github.com/DeusData/codebase-memory-mcp/issues)
- **Security:** [SECURITY.md](SECURITY.md) — reporting, false positives
- **Research Paper:** [arXiv:2603.27277](https://arxiv.org/abs/2603.27277)

---

## TL;DR — Cheat Sheet

| Task | Command |
|------|---------|
| **Install** | `curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh \| bash` |
| **Index project** | Ask your agent: *"Index this project"* |
| **Open graph UI** | `http://localhost:9749` |
| **Re-index** | `codebase-memory-mcp index .` |
| **Daemon status** | `codebase-memory-mcp daemon status` |
| **Stop daemon** | `codebase-memory-mcp daemon stop` |
| **Change UI port** | `codebase-memory-mcp config set ui_port 8080 && codebase-memory-mcp daemon restart` |
| **Uninstall** | `codebase-memory-mcp daemon stop && rm ~/.local/bin/codebase-memory-mcp` |

---

**That's it!** You're ready to explore your codebase like never before. 🧠