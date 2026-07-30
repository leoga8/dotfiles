# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Configs included

- `starship` — `~/.config/starship.toml`
- `ghostty` — `~/.config/ghostty/config`
- `nvim` — `~/.config/nvim/`
- `zsh` — `~/.zshrc`
- `herdr` — `~/.config/herdr/config.toml`
- `claude` — `~/.claude/commands/` (global Claude Code slash commands)
- `opencode` — `~/.config/opencode/` and `~/.opencode/commands/` (OpenCode config + slash commands)

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
│   ├── cases/          # new, log, comms, data/
│   ├── mcps/           # linear, notion, slack context docs
│   └── meta/           # scaffold (new workflow/pipeline generator)
└── pipelines/
    └── code/           # implement, develop
```

The `claude` and `opencode` stow packages contain shims — tiny `.md` files that reference these paths. Shims are the only workflow-related thing tracked in git, so the repo stays conflict-free across machines. Each machine has its own `~/Documents/code/` with only the workflows relevant to it.

### Shim → workflow mapping

| Shim | Workflow |
|------|----------|
| `/hello` | `obsidian/daily-open` |
| `/bills` | `obsidian/bills` |
| `/inbox` | `obsidian/inbox-process` |
| `/vault-setup` | `obsidian/vault-setup` |
| `/wrap-up` | `obsidian/vault-update` |
| `/spec` | `code/spec` |
| `/write` | `code/write` |
| `/refactor` | `code/refactor` |
| `/review-code` | `code/review-code` |
| `/test` | `code/test` |
| `/project-setup` | `code/project-setup` |
| `/optimize` | `database/optimize` |
| `/query` | `database/query` |
| `/refresh-erd` | `database/refresh-erd` |
| `/cellular` | `connectivity/connectivity` |
| `/trace` | `connectivity/trace` |
| `/new` | `cases/new` |
| `/log` | `cases/log` |
| `/comms` | `cases/comms` |
| `/scaffold` | `meta/scaffold` |
| `/implement` | `pipelines/code/implement` |
| `/develop` | `pipelines/code/develop` |

### Personal vs work laptop

On a **work laptop**: clone this repo and stow as usual. Then create `~/Documents/code/` with only the workflows relevant to that machine (skip `obsidian/`, include `cases/` and `connectivity/` if needed). The shims work regardless — a missing workflow file just means that command isn't used there.

> On a new machine: create `~/Documents/code/workflows/` and `~/Documents/code/pipelines/`, then populate with the workflows you need.

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
stow --no-folding --target=$HOME ghostty
stow --no-folding --target=$HOME herdr
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

See [installs.md](./installs.md) for all the commands to install software and tools on a new machine.
