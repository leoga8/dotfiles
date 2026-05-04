#!/bin/bash
# check-daily-exists.sh
# Checks if today's daily note exists in the vault.
# Usage: ./check-daily-exists.sh <vault-root>
# Returns: "true" if found, "false" if not, with the expected path in both cases.

VAULT="${1:-.}"
TODAY=$(date +%Y-%m-%d)
YEAR=$(date +%Y)
MONTH=$(date +%m)
PATH_EXPECTED="$VAULT/raw/daily/$YEAR/$MONTH/$TODAY.md"

if [ -f "$PATH_EXPECTED" ]; then
  echo "true: $PATH_EXPECTED"
else
  echo "false: $PATH_EXPECTED"
fi
