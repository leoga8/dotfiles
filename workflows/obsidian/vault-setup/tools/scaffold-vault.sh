#!/bin/bash
# scaffold-vault.sh
# Creates the full vault folder structure from scratch.
# Usage: ./scaffold-vault.sh <vault-root>
# Note: only creates folders — files (templates, AGENTS.md, etc.) are created by the AI workflow.

VAULT="${1:-.}"

if [ -z "$1" ]; then
  echo "error: vault root path is required"
  echo "usage: ./scaffold-vault.sh <vault-root>"
  exit 1
fi

mkdir -p \
  "$VAULT/add" \
  "$VAULT/hubs" \
  "$VAULT/maps" \
  "$VAULT/raw/projects" \
  "$VAULT/raw/tasks" \
  "$VAULT/raw/books" \
  "$VAULT/raw/games" \
  "$VAULT/raw/mate" \
  "$VAULT/raw/bookmarks" \
  "$VAULT/raw/bills" \
  "$VAULT/raw/daily" \
  "$VAULT/raw/fitness" \
  "$VAULT/raw/templates" \
  "$VAULT/raw/_important" \
  "$VAULT/src/img" \
  "$VAULT/src/pdf" \
  "$VAULT/src/excalidraw" \
  "$VAULT/workflows"

echo "scaffolded: $VAULT"
echo ""
echo "folders created:"
find "$VAULT" -type d | sort | sed "s|$VAULT/||" | grep -v "^\.$"
