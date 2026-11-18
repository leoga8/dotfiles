#!/usr/bin/env zsh
# maintenance.zsh — run periodically to keep your system up to date
# Usage: zsh ~/.dotfiles/maintenance.zsh

run_cmd() {
	echo "\n[TX] :: $1"
	eval "$1" && echo "[OK]" || echo "[WARN] :: command failed: $1"
}

echo "[INFO] :: Maintenance start: $(date)"

if [[ $(uname) == "Darwin" ]]; then
	# Mac OS
	cmds=(
		# Update Oh-My-ZSH
		"zsh $ZSH/tools/upgrade.sh"
		# Update Homebrew
		"brew update"
		# Upgrade formulae
		"yes | brew upgrade"
		# Upgrade casks
		"yes | brew upgrade --cask"
		# Upgrade casks that ignore brew upgrade --cask (auto-update flag)
		"yes | brew upgrade --cask obsidian"
		"yes | brew upgrade --cask warp"
		"yes | brew upgrade --cask spotify"
		"yes | brew upgrade --cask brave-browser"
		"yes | brew upgrade --cask claude-code"
		"yes | brew upgrade --cask claude"
		# "yes | brew upgrade --cask dbeaver-community"
		# Cleanup space
		"brew cleanup --prune=all"
		# Diagnose any issues
		"brew doctor"
		# Uninstall dependencies no longer needed
		"brew autoremove"
		# Trim uv's package cache (uv itself upgrades with brew)
		"uv cache prune"
	)
else
	# Debian/Raspbian
	cmds=(
		# Update Oh-My-ZSH
		"yes | zsh $ZSH/tools/upgrade.sh"
		# Update
		"sudo apt-get update"
		# Upgrade
		"sudo apt-get upgrade -y"
		# Remove packages not needed
		"sudo apt autoremove -y"
		# uv (installed with its own installer here): upgrade it and trim its cache
		"uv self update"
		"uv cache prune"
	)
fi

for cmd in "${cmds[@]}"; do
	run_cmd "$cmd"
done

echo "\n[INFO] :: Maintenance done: $(date)"
