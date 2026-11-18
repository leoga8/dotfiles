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

The automation logic lives **outside this repo** at `~/Documents/code/`, which is its own git repo, [agent-workspace](https://github.com/leoga8/agent-workspace) (private). It tracks only the framework, and job content stays local to each machine. This repo tracks the one-line slash-command shims that point into it. To set up `~/Documents/code` on a new machine, follow the agent-workspace README.

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
├── workflows/          # by domain: obsidian, code, database, meta (+ solutions on the work laptop)
│   └── <domain>/<name>/{prompts,context,tools}   # context/ = static reference only; no data/ folders
├── pipelines/          # by domain, prompts only: obsidian, code (+ implement, develop), database, meta/scaffold
├── planner/
│   ├── core.md         # shared rules: discovery, modes, ticket + plan formats, model tiers, drafts
│   ├── sources.md      # how to fetch / comment / set status: manual, linear, helpscout
│   ├── assistant/      # personal planner  → /assistant   (prompts/, config.md)
│   └── work/           # work planner      → /work (+ /solutions alias)   (prompts/, config.md, + shared-repo files; not in git)
├── orchestration/      # personal only — never shared
│   ├── state-machine.md
│   └── tickets/        # process a set of tickets
└── _archive/           # retired content (old cases pipeline, reports, customer files) — moved, never deleted
```

### Planners are the only slash commands

| shim | planner | scope |
|------|---------|-------|
| `/assistant` | `planner/assistant` | personal — domains and vault in `planner/assistant/config.md` |
| `/work` | `planner/work` | work — domains, vault and ticket sources in `planner/work/config.md` |
| `/solutions` | `planner/work` | alias of `/work`; the name teammates use in the shared repo |

Talk to them in natural language (`/assistant write tests for src/foo.py`, `/work process today's tickets`). On every call a planner globs `~/Documents/code/*/**/prompts/*.md` and reads each file's `# title`, `>` description and optional `tier`/`approval` frontmatter, so **new workflows, pipelines, planners and orchestrations need no new shims** — only their domain listed in the planner config. With no request it shows a menu of everything in scope, including creating new workflows/pipelines/planners/orchestrations (via the `meta` scaffold).

Both shims are shared on every machine. A machine without a planner's content (e.g. `/work` on the personal laptop) simply has nothing in scope for it. A new planner = new shim pair, created by the `new-planner` scaffold.

Headless use (for a future trigger): `claude -p "/work process today's tickets"`.

### Model tiers

Plan steps carry a tier that sets the model and effort of the worker that runs them:

| tier | Claude Code | OpenCode (`agents` in `opencode.json`) |
|------|-------------|------------------------------------------|
| fast | haiku, low effort | `fast` → `openai/gpt-6-luna#low` (ChatGPT subscription; needs `opencode auth login` with OpenAI) |
| standard | sonnet, medium effort | `standard` → `openai/gpt-6-sol#medium` (ChatGPT subscription) |
| deep | opus, high effort | `deep` → `anthropic/claude-opus-5-5#high` (Anthropic API key) |

The work orchestrator itself runs at low effort: on sonnet in Claude Code (`claude --model sonnet --effort low`), and on GPT-6 Sol in OpenCode, set by `~/Documents/code/opencode.json` (`"model": "openai/gpt-6-sol#low"`, stowed from the `opencode` package). `~/Documents/code/automation/work-morning.sh [--claudecode | --opencode]` starts it.

In Rex, each step runs as its own tab, running the same agent as the orchestrator (Claude Code, or OpenCode with the tier agent's model), started by `~/Documents/code/automation/rex-worker.sh` (see `automation/workers.md`), so you can switch to a worker to watch or answer it. Elsewhere (no Rex, teammates) steps run as in-process subagents with the same model and effort.

### Tickets hold all per-case files

```
<tickets_path>/<id>/<id>.md         # ticket note + every input and output file for that ticket
<vault>/raw/runs/YYYY-MM-DD-<slug>.md
```

`tickets_path` is set per planner config — `<vault>/raw/tickets` on your machines, `<repo>/tickets` (gitignored) for teammates.

- Ids: `YYYYMMDD-<slug>` (manual) or `<source>-<external-id>` (e.g. `linear-SOL-1234`)
- Frontmatter `status` follows `orchestration/state-machine.md`; sections `## ticket`, `## plan`, `## drafts`, `## outputs`, `## log`
- Replaces the old `/cases` pipeline and every `data/` / `reports/` folder — workflows read inputs from and write outputs to the ticket folder; `context/` holds only static reference
- The daily note template has a `## tickets` section; "process the tickets in today's daily note" runs them
- **Dry run:** comments and status changes for Linear/HelpScout are written to `## drafts` and only sent after explicit approval

### Shared team repo (`solutions-workflows`)

Teammates get `/solutions` only: `planner/core.md`, `planner/sources.md`, the work planner (renamed back to `solutions` by the sync), and the in-scope pipelines and workflows. Never shared: `/assistant`, `orchestration/`, configs, tickets, `_archive/`, any future trigger. Their setup guide is `planner/work/INSTALL.md` (synced to the repo root).

To share changes: on the work laptop, `/work sync the shared repo` (runs `workflows/meta/sync-shared-repo`) → review the staged diff in the repo → `git commit` and `git push` yourself.

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

The `opencode` package also links `~/Documents/code/opencode.json`, which sets the work orchestrator's OpenCode model (`openai/gpt-6-sol#low`, ChatGPT subscription) for sessions started in `~/Documents/code`. OpenCode's TUI has no model flag, so `work-morning.sh --opencode` relies on it. On a machine without an OpenAI login, pick another model in OpenCode.

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
