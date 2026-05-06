#!/bin/bash
# create-daily-note.sh
# Creates today's daily note from the vault template.
# Usage: ./create-daily-note.sh <vault-root>
# Exits with error if the note already exists.

VAULT="${1:-.}"
TODAY=$(date +%Y-%m-%d)
YEAR=$(date +%Y)
MONTH=$(date +%m)
TARGET_DIR="$VAULT/raw/daily/$YEAR/$MONTH"
TARGET_FILE="$TARGET_DIR/$TODAY.md"
TEMPLATE="$VAULT/raw/templates/daily.md"

if [ -f "$TARGET_FILE" ]; then
  echo "error: daily note already exists at $TARGET_FILE"
  exit 1
fi

if [ ! -f "$TEMPLATE" ]; then
  echo "error: template not found at $TEMPLATE"
  exit 1
fi

mkdir -p "$TARGET_DIR"
sed "s/{{date:YYYY-MM-DD}}/$TODAY/g" "$TEMPLATE" > "$TARGET_FILE"
echo "created: $TARGET_FILE"
