#!/bin/bash
# list-inbox.sh
# Lists all files currently in the add/ inbox with basic metadata.
# Usage: ./list-inbox.sh <vault-root>

VAULT="${1:-.}"
INBOX="$VAULT/add"

if [ ! -d "$INBOX" ]; then
  echo "error: inbox not found at $INBOX"
  exit 1
fi

count=0
for f in "$INBOX"/*.md; do
  [ -f "$f" ] || continue
  name=$(basename "$f")
  size=$(wc -l < "$f")
  created=$(stat -f "%SB" -t "%Y-%m-%d" "$f" 2>/dev/null || stat -c "%y" "$f" 2>/dev/null | cut -d' ' -f1)
  echo "$name | $size lines | created: $created"
  count=$((count + 1))
done

if [ "$count" -eq 0 ]; then
  echo "inbox is empty"
fi
