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

The automation logic lives **outside this repo** at `~/Documents/code/` (local to each machine, no git). This repo tracks two one-line shims plus **reference copies** of the essential planner and state-machine files under `examples/` (see [Recreate the planner + state machine](#recreate-the-planner--state-machine)).

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
│   └── solutions/      # work planner      → /solutions   (prompts/, config.md, + shared-repo files)
├── orchestration/      # personal only — never shared
│   ├── state-machine.md
│   └── tickets/        # process a set of tickets
└── _archive/           # retired content (old cases pipeline, reports, customer files) — moved, never deleted
```

### Planners are the only slash commands

| shim | planner | scope |
|------|---------|-------|
| `/assistant` | `planner/assistant` | personal — domains and vault in `planner/assistant/config.md` |
| `/solutions` | `planner/solutions` | work — domains, vault and ticket sources in `planner/solutions/config.md` |

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

Teammates get `/solutions` only: `planner/core.md`, `planner/sources.md`, the solutions planner, and the in-scope pipelines and workflows. Never shared: `/assistant`, `orchestration/`, configs, tickets, `_archive/`, any future trigger. Their setup guide is `planner/solutions/INSTALL.md` (synced to the repo root).

To share changes: on the work laptop, `/solutions sync the shared repo` (runs `workflows/meta/sync-shared-repo`) → review the staged diff in the repo → `git commit` and `git push` yourself.

---

## Work machine setup

> Use this section to set up a new work laptop or recover after reinstalling. Point any Claude instance at this section and it can do everything here.

### what goes where

| location | what it contains | managed by |
|----------|-----------------|------------|
| `~/.dotfiles/` | starship, nvim, zsh, `/assistant` + `/solutions` shims, opencode config | git (this repo, pull-only on work) |
| `~/Documents/code/` | workflows, pipelines, planner, orchestration | local to the machine |
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
├── planner/                # core.md, sources.md, assistant/, solutions/
└── orchestration/          # state-machine.md, tickets/
```

### step 3 — planner config

Edit `~/Documents/code/planner/solutions/config.md`:

```
- **root:** ~/Documents/code
- **vault_path:** ~/Documents/code/obsidian/leo-work-os
- **tickets_path:** <vault_path>/raw/tickets
- **domains:** solutions, csp, onboard, rate-card, code, database, meta, obsidian
- **sources:** manual, linear, helpscout
```

`domains` must match the folder names under `workflows/` and `pipelines/` for the work pipelines.

If there is nothing to transfer in step 2, follow [Recreate the planner + state machine](#recreate-the-planner--state-machine) first. It starts from `examples/code/planner/solutions/config.example.md`, which already has these values.

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
2. For the vault: `/solutions set up a new work vault` → routes to obsidian vault-setup (greenfield) — scaffolds the vault including `raw/tickets/` and `raw/runs/`
3. For work-specific workflows: rebuild the static `context/` reference files in `workflows/solutions/*` with the new employer's context
4. Set `vault_path` in `planner/solutions/config.md`

---

## Recreate the planner + state machine

> Use this on any machine (personal or work) where `~/Documents/code/` doesn't exist yet. Point Claude at this section and it can follow it step by step. `examples/` is reference only: it is never stowed, and real configs, tickets, secrets and work-domain content never go in it.

### what's in `examples/`

```
examples/
├── code/                                  # mirrors ~/Documents/code/
│   ├── planner/
│   │   ├── core.md                        # shared rules: discovery, modes, ticket + plan formats, tiers, drafts
│   │   ├── sources.md                     # manual / linear / helpscout: get, comment, set status
│   │   ├── assistant/{prompts/assistant.md, config.example.md}
│   │   └── solutions/{prompts/solutions.md, config.example.md}
│   ├── orchestration/
│   │   ├── state-machine.md               # ticket statuses, transitions, drafts/approval rules
│   │   └── tickets/prompts/tickets.md     # processes a set of tickets through planners
│   ├── workflows/meta/new-{workflow,pipeline,planner,orchestration}/prompts/*.md
│   └── pipelines/meta/scaffold/prompts/scaffold.md
├── vault/raw/templates/ticket.md          # ticket note template for the vault
└── secrets.example                        # ~/.secrets placeholders (work only)
```

The scaffold's `sync-shared-repo` option is work-only and isn't included. Add it on the work laptop.

### steps

1. **Check first.** If `~/Documents/code/planner/core.md` already exists, stop: this machine already has its files.
2. **Copy the examples in** without overwriting anything:
   ```bash
   mkdir -p ~/Documents/code
   cp -Rn ~/.dotfiles/examples/code/ ~/Documents/code/
   ```
   On a work machine without orchestration, delete `~/Documents/code/orchestration/` (and `planner/assistant/` if you don't want it there).
3. **Create each planner config** you use on this machine and fill in `vault_path` (and `domains` if needed):
   ```bash
   cp ~/Documents/code/planner/assistant/config.example.md ~/Documents/code/planner/assistant/config.md
   cp ~/Documents/code/planner/solutions/config.example.md ~/Documents/code/planner/solutions/config.md
   ```
   Placeholders are fine to leave: the planner asks for any missing value on first run and saves it.
4. **Vault.** The planner and state machine expect these in `<vault_path>`:
   - `AGENTS.md` (vault structure and schemas, read in question mode)
   - `raw/tickets/`, `raw/runs/`, `raw/daily/YYYY/MM/`
   - `raw/templates/daily.md` with a `## tickets` section (orchestration reads it for "today's tickets")
   - `raw/templates/ticket.md`: copy it from `examples/vault/raw/templates/ticket.md`

   For a brand-new vault, scaffold it with the obsidian `vault-setup` workflow if present, or `/assistant create a workflow` for one.
5. **Rebuild domain workflows and pipelines** (`obsidian`, `code`, `database`, work domains) as needed with `/assistant create a workflow ...` or `/assistant create a pipeline ...`. Each new domain must also be listed in the planner's `domains`.
6. **Verify:**
   - `claude -p "/assistant"` (or `/solutions`) shows the menu, including **process tickets** when `orchestration/` exists
   - `/assistant track setup smoke test` creates `<tickets_path>/<id>/<id>.md` with `status: new`. Delete that folder afterwards.

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

### keeping examples current

After changing any of the essential files in `~/Documents/code/`, copy them back into `examples/` and commit:

```bash
cd ~/Documents/code
for f in planner/core.md planner/sources.md \
         planner/assistant/prompts/assistant.md planner/solutions/prompts/solutions.md \
         orchestration/state-machine.md orchestration/tickets/prompts/tickets.md \
         workflows/meta/new-{workflow,pipeline,planner,orchestration}/prompts/*.md \
         pipelines/meta/scaffold/prompts/scaffold.md; do
  cp "$f" ~/.dotfiles/examples/code/"$f"
done
```

Never copy the real `config.md` files: edit the `config.example.md` files in `examples/` directly.

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
