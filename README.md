# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Configs included

- `tmux` — `~/.config/tmux/tmux.conf`
- `starship` — `~/.config/starship.toml`
- `ghostty` — `~/.config/ghostty/config`
- `nvim` — `~/.config/nvim/`
- `zsh` — `~/.zshrc`

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

### 3. Stow the configs

```bash
cd ~/.dotfiles
stow --no-folding --target=$HOME tmux
stow --no-folding --target=$HOME starship
stow --no-folding --target=$HOME ghostty
stow --no-folding --target=$HOME nvim
stow --no-folding --target=$HOME zsh
```

This creates symlinks from `~/.config/` back into `~/.dotfiles/`.

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

Configs are symlinked so any edits made in `~/.config/` are automatically reflected in `~/.dotfiles/`. Just commit and push periodically:

```bash
cd ~/.dotfiles
git add .
git commit -m "describe what changed"
git push
```

---

## Using dotfiles on another machine

### 1. Install Stow and clone the repo

```bash
# macOS
brew install stow

# Debian/Ubuntu
sudo apt install stow

git clone git@github.com:leoga8/dotfiles.git ~/.dotfiles
```

### 2. Remove any existing configs that would conflict

Before stowing, remove any existing files or directories that stow would try to overwrite. Use `unlink` for symlinks and `rm` for regular files:

```bash
unlink ~/.config/tmux/tmux.conf   # if it's a symlink
rm ~/.config/tmux/tmux.conf       # if it's a regular file

unlink ~/.config/starship.toml
unlink ~/.config/ghostty/config
rm -rf ~/.config/nvim
unlink ~/.zshrc
rm ~/.zshrc                       # if it's a regular file
```

### 3. Stow the configs

```bash
cd ~/.dotfiles
stow --no-folding --target=$HOME tmux
stow --no-folding --target=$HOME starship
stow --no-folding --target=$HOME ghostty
stow --no-folding --target=$HOME nvim
stow --no-folding --target=$HOME zsh
```

### 4. Pull future changes

Once set up, keeping in sync with the latest changes is just:

```bash
cd ~/.dotfiles
git pull
```

---

## Software installs

See [installs.md](./installs.md) for all the commands to install software and tools on a new machine.
