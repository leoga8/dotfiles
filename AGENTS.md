Before anything else, read `~/Documents/code/RULES.md` and follow it.

# ~/.dotfiles

- Personal dotfiles managed with GNU Stow. Each top-level folder is a stow package; files inside mirror their path under `$HOME`.
- Edit this repo on the personal laptop only. The work laptop pulls and never commits here.
- Stow with `stow --no-folding --target=$HOME <package>`. Never put a secret in this repo; `examples/secrets.example` is the template.
- The automation lives in `~/Documents/code` (its own repo). This repo holds only the slash-command shims and the OpenCode config that point into it. Don't copy the workspace's tables or rules here; link to its README.
- After adding a package or changing the layout, update `README.md` in the same change.
