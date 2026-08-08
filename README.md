# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Configs included

- `starship` — `~/.config/starship.toml`
- `nvim` — `~/.config/nvim/`
- `zsh` — `~/.zshrc`
- `claude` — `~/.claude/commands/` (global Claude Code slash commands)
- `opencode` — `~/.config/opencode/` and `~/.opencode/commands/` (OpenCode config + slash commands)

### Stale configs

These packages are kept in the repo but are **no longer stowed** on any machine:

- `ghostty` — `~/.config/ghostty/config` (not in active use)
- `herdr` — `~/.config/herdr/config.toml` (not in active use)

---

## Workflows & Pipelines

Workflows and pipelines live **outside this repo** at `~/Documents/code/` — iCloud-backed on macOS, no git needed:

```
~/Documents/code/
├── workflows/
│   ├── obsidian/       # daily-open, bills, inbox-process, vault-setup, vault-update
│   ├── code/           # project-setup, spec, write, refactor, review-code, test
│   ├── database/       # optimize, query, refresh-erd
│   ├── connectivity/   # connectivity, trace
│   ├── cases/          # new, comms, data/
│   └── meta/           # new-workflow, new-pipeline
├── pipelines/
│   ├── obsidian/       # /obsidian pipeline
│   ├── code/           # /code pipeline (+ implement, develop sub-pipelines)
│   ├── database/       # /database pipeline
│   ├── connectivity/   # /connectivity pipeline
│   ├── cases/          # /cases pipeline
│   └── meta/           # /scaffold pipeline
└── mcps/               # linear, notion, slack context docs
```

The `claude` and `opencode` stow packages contain shims — tiny `.md` files that reference these paths. Shims are the only workflow-related thing tracked in git, so the repo stays conflict-free across machines. Each machine has its own `~/Documents/code/` with only the workflows relevant to it.

### Shim → pipeline mapping

| Shim | Pipeline | Options |
|------|----------|---------|
| `/obsidian` | `pipelines/obsidian` | daily-open, wrap-up, inbox, bills, vault-setup |
| `/code` | `pipelines/code/code` | spec, write, review, refactor, test, project-setup, implement, develop |
| `/database` | `pipelines/database` | query, optimize, refresh-erd |
| `/connectivity` | `pipelines/connectivity` | cellular, trace |
| `/cases` | `pipelines/cases` | new, comms |
| `/scaffold` | `pipelines/meta/scaffold` | new-workflow, new-pipeline |

### Personal vs work laptop

The **6 shared shims** above live in this repo and work on both personal and work machines — they all point to `~/Documents/code/` which exists independently on each machine.

The **work laptop** has 3 additional work-specific pipelines (`/csp`, `/onboard`, `/rate-card`) whose shims are **not** in this repo. They live in `~/Documents/code/dotfiles/` on the work machine and are stowed from there as a second stow pass (see work machine setup below).

---

## Work machine setup

> Use this section to set up a new work laptop or recover after reinstalling. Point any Claude instance at this section and it can do everything here.

### what goes where

| location | what it contains | managed by |
|----------|-----------------|------------|
| `~/.dotfiles/` | starship, nvim, zsh, 6 shared shims | git (this repo, pull-only on work) |
| `~/Documents/code/` | workflows, pipelines, mcps, vault, 3 work-specific shims | iCloud (work machine's own Apple ID) |
| `~/Documents/code/obsidian/leo-work-os/` | work Obsidian vault | iCloud (work machine's own Apple ID) |

### step 1 — clone dotfiles and stow shared config

```bash
git clone git@github.com:leoga8/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow --no-folding --target=$HOME starship
stow --no-folding --target=$HOME nvim
stow --no-folding --target=$HOME zsh
stow --no-folding --target=$HOME claude
stow --no-folding --target=$HOME opencode
```

This gives you all 6 shared pipeline shims in `~/.claude/commands/` and `~/.opencode/commands/`.

### step 2 — transfer ~/Documents/code/

Transfer the staged `~/Documents/code/` content (workflows, pipelines, mcps, dotfiles, obsidian vault) to the work machine. The expected top-level structure:

```
~/Documents/code/
├── obsidian/
│   └── leo-work-os/     # work Obsidian vault
├── workflows/
│   ├── obsidian/        # daily-open, inbox-process, vault-setup, vault-update
│   ├── code/            # project-setup, spec, write, refactor, review-code, test
│   ├── database/        # optimize, query, refresh-erd (+ real ERD/schema data files)
│   ├── connectivity/    # cellular, trace
│   ├── cases/           # new, comms, csp-docs, customer-onboarding, rate-cards, data/
│   └── meta/            # new-workflow, new-pipeline
├── pipelines/
│   ├── obsidian/        # /obsidian pipeline (no bills)
│   ├── code/            # /code, /implement, /develop pipelines
│   ├── database/        # /database pipeline
│   ├── connectivity/    # /connectivity pipeline
│   ├── cases/           # /cases pipeline
│   ├── meta/            # /scaffold pipeline
│   ├── csp/             # /csp pipeline
│   ├── onboard/         # /onboard pipeline
│   └── rate-card/       # /rate-card pipeline
├── mcps/                # linear, slack, notion MCP setup docs
└── dotfiles/            # work-specific shims (stowed in step 3)
    ├── claude/.claude/commands/
    │   ├── csp.md
    │   ├── onboard.md
    │   └── rate-card.md
    └── opencode/.opencode/commands/
        ├── csp.md
        ├── onboard.md
        └── rate-card.md
```

### step 3 — stow work-specific shims

```bash
cd ~/Documents/code
stow --no-folding --target=$HOME dotfiles
```

This adds `/csp`, `/onboard`, `/rate-card` to `~/.claude/commands/` and `~/.opencode/commands/` alongside the 6 from step 1. No conflicts — different filenames.

### full shim list on work machine

| shim | pipeline | source |
|------|----------|--------|
| `/obsidian` | `pipelines/obsidian` | `~/.dotfiles` (shared) |
| `/code` | `pipelines/code/code` | `~/.dotfiles` (shared) |
| `/database` | `pipelines/database` | `~/.dotfiles` (shared) |
| `/connectivity` | `pipelines/connectivity` | `~/.dotfiles` (shared) |
| `/cases` | `pipelines/cases` | `~/.dotfiles` (shared) |
| `/scaffold` | `pipelines/meta/scaffold` | `~/.dotfiles` (shared) |
| `/csp` | `pipelines/csp` | `~/Documents/code/dotfiles` (work-only) |
| `/onboard` | `pipelines/onboard` | `~/Documents/code/dotfiles` (work-only) |
| `/rate-card` | `pipelines/rate-card` | `~/Documents/code/dotfiles` (work-only) |

### step 4 — vault config

Update `~/Documents/code/workflows/cases/data/config.md` to confirm the vault path:

```
vault_path: ~/Documents/code/obsidian/leo-work-os
```

### step 5 — MCP setup

Each MCP needs its API key exported in `~/.zshrc` and configured in `~/.claude/settings.json` and `~/.config/opencode/opencode.json`. Setup instructions are in `~/Documents/code/mcps/`:

- `mcps/linear.md` → Linear API key
- `mcps/slack.md` → Slack bot token + team ID
- `mcps/notion.md` → Notion integration token

### new job / new work laptop

If starting fresh with a new employer:
1. Follow steps 1–3 above
2. For the vault: run `/obsidian` → vault-setup → work (greenfield) — it scaffolds the full work vault structure from `~/Documents/code/workflows/obsidian/vault-setup/`
3. For work-specific workflows (`/csp`, `/onboard`, `/rate-card`): the pipeline stubs are in place but their workflows reference employer-specific data files. You'll need to rebuild the `data/` folders in `workflows/cases/csp-docs/`, `workflows/cases/customer-onboarding/`, and `workflows/cases/rate-cards/` with the new employer's context
4. Update `~/Documents/code/workflows/cases/data/config.md` with the new vault path

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
rm -rf ~/.config/herdr
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
# stow --no-folding --target=$HOME ghostty   # stale — not in active use
# stow --no-folding --target=$HOME herdr     # stale — not in active use
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
