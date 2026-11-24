# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Configs included

- `starship` — `~/.config/starship.toml`
- `nvim` — `~/.config/nvim/`
- `zsh` — `~/.zshrc`
- `claude` — `~/.claude/commands/` (global Claude Code slash commands)
- `opencode` — `~/.config/opencode/` and `~/.opencode/commands/` (OpenCode config + slash commands)

---

## Automation: planners, pipelines, workflows

The automation logic lives **outside this repo** at `~/Documents/code/`, its own git repo, [agent-workspace](https://github.com/leoga8/agent-workspace) (private). This repo tracks only the one-line slash-command shims that point into it, and the OpenCode config.

For the layers, planners, model tiers, tickets and the shared team repo, see "how it fits together" in `~/Documents/code/README.md`. Session rules for every agent are in `~/Documents/code/RULES.md`.


---

## Work machine setup

> Use this section to set up a new work laptop or recover after reinstalling. Point any Claude instance at this section and it can do everything here.

### what goes where

| location | what it contains | managed by |
|----------|-----------------|------------|
| `~/.dotfiles/` | starship, nvim, zsh, `/assistant` + `/work` + `/solutions` shims, opencode config | git (this repo, pull-only on work) |
| `~/Documents/code/` | framework: planner core, orchestration, automation, generic workflows and pipelines | git ([agent-workspace](https://github.com/leoga8/agent-workspace)) |
| `~/Documents/code/` job folders | `planner/work/`, `workflows/solutions/`, `pipelines/{csp,onboard,rate-card}/`, configs | local to the machine (ignored by git) |
| `~/Documents/code/obsidian/leo-work-os/` | work Obsidian vault (tickets live in `raw/tickets/`) | local to the machine |

### step 1 — clone dotfiles and stow

```bash
git clone git@github.com:leoga8/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow --no-folding --target=$HOME starship
stow --no-folding --target=$HOME nvim
stow --no-folding --target=$HOME zsh
stow --no-folding --target=$HOME claude
stow --no-folding --target=$HOME opencode
```

This gives you `/assistant`, `/work` and `/solutions` in `~/.claude/commands/` and `~/.opencode/commands/`. No second stow pass is needed — work-only shims are gone.

The `opencode` package also links `~/Documents/code/opencode.json`, which sets the work orchestrator's OpenCode model (`claude-agent/sonnet#low`) for sessions started in `~/Documents/code`. OpenCode's TUI has no model flag, so `work-morning.sh --opencode` relies on it. It needs the Claude Agent login in OpenCode.

### step 2 — ~/Documents/code/

Clone (or, if the folder already has job content, adopt in place) [agent-workspace](https://github.com/leoga8/agent-workspace), then run `~/Documents/code/setup.zsh --check`. Its README has both procedures. The job content (`planner/work/`, `workflows/solutions/`, `pipelines/{csp,onboard,rate-card}/`, the vault) isn't in git. Transfer it from the old work laptop, or rebuild it at a new job.

### step 3 — planner config

Edit `~/Documents/code/planner/work/config.md`:

```
- **root:** ~/Documents/code
- **vault_path:** ~/Documents/code/obsidian/leo-work-os
- **tickets_path:** <vault_path>/raw/tickets
- **domains:** solutions, csp, onboard, rate-card, code, database, meta, obsidian
- **sources:** manual, linear, helpscout
```

`domains` must match the folder names under `workflows/` and `pipelines/` for the work pipelines.

`setup.zsh` creates `config.md` from `config.example.md` when it's missing.

### step 4 — MCP setup

`~/.config/opencode/opencode.json` (stowed from this repo) defines four MCP servers. On a machine where you don't use them they just stay unauthenticated, so the file is safe on personal machines too.

| server | type | how to connect |
|--------|------|----------------|
| Linear | remote (`https://mcp.linear.app/mcp`) | `opencode mcp auth linear` — browser OAuth |
| Notion | remote (`https://mcp.notion.com/mcp`) | `opencode mcp auth notion` — browser OAuth |
| Sigma | remote (`https://aws-api.sigmacomputing.com/mcp/v2`) | `opencode mcp auth sigma` — browser OAuth |
| HelpScout | local (`npx help-scout-mcp-server`) | env vars below |

Add the HelpScout app credentials to `~/.secrets` (sourced by `~/.zshrc`) on the **work laptop only**. Start from `cp ~/.dotfiles/examples/secrets.example ~/.secrets`:

```bash
# HelpScout MCP for OpenCode
export HELPSCOUT_APP_ID="your-app-id"
export HELPSCOUT_APP_SECRET="your-app-secret"
```

Check everything with `opencode mcp list`.

Claude Code MCPs are enabled org-wide via Hologram's Claude settings — no manual config needed there.

### new job / new work laptop

1. Follow steps 1–3 above
2. For the vault: `/work set up a new work vault` (or let `setup.zsh` scaffold it from `vault_path`) → routes to obsidian vault-setup (greenfield) — scaffolds the vault including `raw/tickets/` and `raw/runs/`
3. For work-specific workflows: rebuild the static `context/` reference files in `workflows/solutions/*` with the new employer's context
4. Set `vault_path` in `planner/work/config.md`, and add the new job's terms to `automation/safety-terms.txt`

---

## Bootstrap on a new machine

### 1. Install Stow

```bash
# macOS
brew install stow

# Debian/Ubuntu
sudo apt install stow
```

### 2. Clone the repo

```bash
git clone git@github.com:leoga8/dotfiles.git ~/.dotfiles
```

### 3. Remove any existing configs that would conflict

Before stowing, remove any existing files that stow would try to overwrite. Use `unlink` for symlinks and `rm` for regular files:

```bash
unlink ~/.config/starship.toml
rm -rf ~/.config/nvim
unlink ~/.zshrc
rm ~/.zshrc                       # if it's a regular file
```

### 4. Stow the configs

```bash
cd ~/.dotfiles
stow --no-folding --target=$HOME starship
stow --no-folding --target=$HOME nvim
stow --no-folding --target=$HOME zsh
stow --no-folding --target=$HOME claude
stow --no-folding --target=$HOME opencode
```

This creates symlinks from `$HOME` back into `~/.dotfiles/`.

---

## Adding a new config

Use `mv` to move the original file into the repo, preserving the path structure relative to `$HOME`, then stow it.

Example for a new config at `~/.config/foo/config`:

```bash
mkdir -p ~/.dotfiles/foo/.config/foo
mv ~/.config/foo/config ~/.dotfiles/foo/.config/foo/config

cd ~/.dotfiles
stow --no-folding --target=$HOME foo

git add .
git commit -m "add foo config"
git push
```

---

## Useful Stow flags

| Flag | Purpose |
|---|---|
| `-v` | Verbose — shows every symlink being created |
| `-n` | Dry run — shows what would happen without doing it |
| `-D` | Unstow — removes symlinks |
| `-R` | Re-stow — unstow then stow again |

---

## Day to day

Configs are symlinked so any edits made in `~/.config/` (or `~/.zshrc`, `~/.claude/`, etc.) are automatically reflected in `~/.dotfiles/`. Just commit and push periodically:

```bash
cd ~/.dotfiles
git add .
git commit -m "describe what changed"
git push
```

To pull updates on another machine:

```bash
cd ~/.dotfiles
git pull
```

---

## Software installs

Run `bootstrap.zsh` on a fresh machine to install all CLI tools and apps:

```bash
zsh ~/.dotfiles/bootstrap.zsh
```

Run `maintenance.zsh` periodically to keep everything up to date:

```bash
zsh ~/.dotfiles/maintenance.zsh
```
