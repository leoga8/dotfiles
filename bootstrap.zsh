#!/usr/bin/env zsh
# bootstrap.sh — run on a fresh macOS machine to install everything
# Usage: zsh ~/.dotfiles/bootstrap.sh

set -e

# ── Prerequisites ──────────────────────────────────────────────────────────────

if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure brew is on PATH (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ── Package list ───────────────────────────────────────────────────────────────

INSTALLS=(
  "brew install --cask rectangle"
  "brew install --cask ghostty"
  "brew install --cask spotify"
  "brew install --cask discord"
  "brew install --cask brave-browser"
  "brew install --cask obsidian"
  "brew install --cask slack"
  "brew install --cask wireshark-app"
  "brew install --cask zoom"
  "brew install --cask 1password"
  "brew install --cask shottr"
  "brew install --cask appcleaner"
  "brew install --cask tunnelblick"
  "brew install jq"
  "brew install fzf"
  "brew install fd"
  "brew install herdr"
  "brew install nvim"
  "brew install fastfetch"
  "brew install lazygit"
  "brew install opencode"
  "brew install starship"
  "brew install speedtest-cli"
  "brew install chafa"
  "brew install slides"
  "brew install stow"
  "brew install tree-sitter-cli"
  "brew install glow"
)

# ── Run ────────────────────────────────────────────────────────────────────────

echo "\n── Installing packages ───────────────────────────────────────────────────"
for cmd in "${INSTALLS[@]}"; do
  echo "\n→ $cmd"
  eval "$cmd" || echo "  skipped (already installed or error)"
done

echo "\nDone! Next: stow your dotfiles."
