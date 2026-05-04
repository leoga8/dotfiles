#!/bin/bash
# move-note.sh
# Moves a note from add/ to the specified raw/ subfolder.
# Usage: ./move-note.sh <vault-root> <filename> <destination-subfolder>
# Example: ./move-note.sh . "my-task.md" "raw/tasks"

VAULT="${1:-.}"
FILE="$2"
DEST_SUBFOLDER="$3"

if [ -z "$FILE" ] || [ -z "$DEST_SUBFOLDER" ]; then
  echo "error: usage: ./move-note.sh <vault-root> <filename> <destination-subfolder>"
  exit 1
fi

SRC="$VAULT/add/$FILE"
DEST_DIR="$VAULT/$DEST_SUBFOLDER"
DEST="$DEST_DIR/$FILE"

if [ ! -f "$SRC" ]; then
  echo "error: file not found at $SRC"
  exit 1
fi

if [ ! -d "$DEST_DIR" ]; then
  echo "error: destination directory not found at $DEST_DIR"
  exit 1
fi

if [ -f "$DEST" ]; then
  echo "error: file already exists at $DEST"
  exit 1
fi

mv "$SRC" "$DEST"
echo "moved: $FILE → $DEST_SUBFOLDER/"
