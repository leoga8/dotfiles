#!/usr/bin/env zsh
# cleanup-herdr.zsh — remove what Herdr left behind after uninstalling it
# Safe to run more than once. Run it after pulling the commit that removed the
# herdr, herdr-app and herdr-core stow packages.
# Usage: zsh ~/.dotfiles/cleanup-herdr.zsh

OC="$HOME/.config/opencode"

run_cmd() {
	echo "\n[TX] :: $1"
	eval "$1" && echo "[OK]" || echo "[WARN] :: command failed: $1"
}

echo "[INFO] :: Herdr cleanup start: $(date)"

# Symlinks into the removed stow packages now point nowhere
for d in "$HOME/.config/herdr" "$HOME/.config/herdr-app" "$HOME/.config/herdr-core"; do
	[[ -d "$d" ]] && run_cmd "find '$d' -type l ! -exec test -e {} \\; -print -delete"
done

# Herdr's OpenCode integration (installed by Herdr, never tracked here)
for f in "$OC/herdr-opencode" "$OC/herdr-tui-session.js" "$OC/plugins/herdr-agent-state.js"; do
	[[ -e "$f" ]] && run_cmd "rm -rf '$f'"
done
[[ -d "$OC/plugins" ]] && rmdir "$OC/plugins" 2>/dev/null
if [[ -f "$OC/cli.json" ]] && grep -q herdr "$OC/cli.json"; then
	run_cmd "jq 'del(.plugins)' '$OC/cli.json' > '$OC/cli.json.new' && mv '$OC/cli.json.new' '$OC/cli.json' && chmod 600 '$OC/cli.json'"
fi
if [[ -f "$OC/tui.jsonc" ]] && grep -q herdr "$OC/tui.jsonc"; then
	run_cmd "rm '$OC/tui.jsonc'"
fi

# Herdr's own config folders: report them, delete by hand once Herdr is gone
left=(${(f)"$(ls -d "$HOME"/.config/herdr* "$HOME"/.local/share/herdr* "$HOME"/.local/bin/hc "$HOME"/.local/bin/herdr* 2>/dev/null)"})
if (( ${#left} )); then
	echo "\n[INFO] :: Herdr files still here (delete them yourself once Herdr is uninstalled):"
	printf '  %s\n' "${left[@]}"
fi

echo "\n[INFO] :: Herdr cleanup done: $(date)"
