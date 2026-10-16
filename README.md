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

The automation logic lives **outside this repo** at `~/Documents/code/` (local to each machine, no git). This repo only tracks two one-line shims.

### Layers

| layer | what it is | lives in |
|-------|-----------|----------|
| workflow | one atomic task (e.g. `test`, `query`) | `workflows/<domain>/<name>/` |
| pipeline | runs one or more workflows (menu-driven or sequential) | `pipelines/<domain>/...` |
| planner | natural-language entry point — discovers what exists and routes a request or ticket to it, picking a model tier per step | `planner/<name>/` |
| orchestration | runs a set of tickets through planners with a state machine; drafts outbound updates | `orchestration/<name>/` |
| trigger | *(future, separate repo)* external automation (e.g. n8n) that calls a planner headlessly | — |

Each layer is a **flat top-level sibling**, split by domain inside. Layers are not nested by call order: pipelines still work without a planner, planners/orchestration are cross-domain, and new layers never move existing paths.

```
~/Documents/code/
├── workflows/          # by domain: obsidian, code, database, meta (+ work domains on the work laptop)
├── pipelines/          # by domain: obsidian, code (+ implement, develop), database, meta/scaffold
├── planner/
│   ├── data/core.md    # shared rules: discovery, modes, plan format, model tiers
│   ├── assistant/      # personal planner  → /assistant
│   └── solutions/      # work planner      → /solutions
├── orchestration/
│   ├── data/           # state-machine.md, sources.md (manual, linear, helpscout)
│   └── tickets/        # process a set of tickets
└── _archive/           # retired content (e.g. the old cases pipeline) — moved, never deleted
```

### Planners are the only slash commands

| shim | planner | scope |
|------|---------|-------|
| `/assistant` | `planner/assistant` | personal — domains and vault in `planner/assistant/data/config.md` |
| `/solutions` | `planner/solutions` | work — domains, vault and ticket sources in `planner/solutions/data/config.md` |

Talk to them in natural language (`/assistant write tests for src/foo.py`, `/solutions process today's tickets`). On every call a planner globs `~/Documents/code/*/**/prompts/*.md` and reads each file's `# title`, `>` description and optional `tier`/`approval` frontmatter, so **new workflows, pipelines, planners and orchestrations need no new shims** — only their domain listed in the planner config. With no request it shows a menu of everything in scope, including creating new workflows/pipelines/planners/orchestrations (via the `meta` scaffold).

Both shims are shared on every machine. A machine without a planner's content (e.g. `/solutions` on the personal laptop) simply has nothing in scope for it. A new planner = new shim pair, created by the `new-planner` scaffold.

Headless use (for a future trigger): `claude -p "/solutions process today's tickets"`.

### Model tiers

Plan steps carry a tier and run as subagents:

| tier | Claude Code | OpenCode (`agents` in `opencode.json`) |
|------|-------------|------------------------------------------|
| fast | haiku | `fast` → `opencode/claude-haiku-5-5` |
| standard | sonnet | `standard` → `opencode/claude-sonnet-5-5` |
| deep | opus | `deep` → `opencode/claude-opus-5-5` |

### Tickets live in the Obsidian vault

```
<vault>/raw/tickets/<id>/<id>.md    # ticket note + its inputs and outputs in the same folder
<vault>/raw/runs/YYYY-MM-DD-<slug>.md
```

- Ids: `YYYYMMDD-<slug>` (manual) or `<source>-<external-id>` (e.g. `linear-SOL-1234`)
- Frontmatter `status` follows `orchestration/data/state-machine.md`; sections `## ticket`, `## plan`, `## drafts`, `## outputs`, `## log`
- Replaces the old `/cases` pipeline and workflow `data/reports/` folders — workflow `data/` keeps only static reference material
- The daily note template has a `## tickets` section; "process the tickets in today's daily note" runs them
- **Dry run:** comments and status changes for Linear/HelpScout are written to `## drafts` and only sent after explicit approval

---

## Work machine setup

> Use this section to set up a new work laptop or recover after reinstalling. Point any Claude instance at this section and it can do everything here.

### what goes where

| location | what it contains | managed by |
|----------|-----------------|------------|
| `~/.dotfiles/` | starship, nvim, zsh, `/assistant` + `/solutions` shims, opencode config | git (this repo, pull-only on work) |
| `~/Documents/code/` | workflows, pipelines, planner, orchestration, mcps | local to the machine |
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

This gives you `/assistant` and `/solutions` in `~/.claude/commands/` and `~/.opencode/commands/`. No second stow pass is needed — work-only shims are gone.

### step 2 — transfer ~/Documents/code/

Transfer `~/Documents/code/` to the work machine. Expected top-level structure:

```
~/Documents/code/
├── obsidian/leo-work-os/   # work Obsidian vault
├── workflows/              # incl. solutions/ (csp-docs, customer-onboarding, rate-cards)
├── pipelines/              # incl. csp/, onboard/, rate-card/
├── planner/                # assistant/, solutions/, data/core.md
├── orchestration/          # tickets/, data/
└── mcps/                   # linear, slack, notion, helpscout setup docs
```

### step 3 — planner config

Edit `~/Documents/code/planner/solutions/data/config.md`:

```
- **vault_path:** ~/Documents/code/obsidian/leo-work-os
- **domains:** solutions, csp, onboard, rate-card, code, database, meta
- **sources:** manual, linear, helpscout
```

`domains` must match the folder names under `workflows/` and `pipelines/` for the work pipelines.

### step 4 — MCP setup

`~/.config/opencode/opencode.json` (stowed from this repo) already has MCP entries for Linear, Slack, Notion and HelpScout configured with env var placeholders — it silently skips any MCP whose env var is not set, so the file is safe on personal machines too.

Add the following to `~/.secrets` (sourced by `~/.zshrc`) on the **work laptop only**:

```bash
# Work MCPs for OpenCode
export LINEAR_API_KEY="lin_api_your_key_here"
export SLACK_BOT_TOKEN="xoxb-your-token-here"
export SLACK_TEAM_ID="T0123ABCDEF"
export NOTION_API_KEY="secret_your_token_here"
export HELPSCOUT_API_KEY="Bearer your-personal-access-token-here"
```

Note: the `Bearer ` prefix is part of the `HELPSCOUT_API_KEY` value.

See `~/Documents/code/mcps/` for how to obtain each credential (`linear.md`, `slack.md`, `notion.md`, `helpscout.md`).

Claude Code MCPs are enabled org-wide via Hologram's Claude settings — no manual config needed there.

### new job / new work laptop

1. Follow steps 1–3 above
2. For the vault: `/solutions set up a new work vault` → routes to obsidian vault-setup (greenfield) — scaffolds the vault including `raw/tickets/` and `raw/runs/`
3. For work-specific workflows: rebuild the static `data/` reference files in `workflows/solutions/*` with the new employer's context
4. Set `vault_path` in `planner/solutions/data/config.md`

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
