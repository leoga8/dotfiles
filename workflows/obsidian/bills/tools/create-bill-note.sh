#!/bin/bash
# create-bill-note.sh
# Creates a bill note for a given vendor and month from the vault template.
# Usage: ./create-bill-note.sh <vault-root> <vendor-name> [YYYY-MM]
# If month is omitted, defaults to current month.

VAULT="${1:-.}"
VENDOR="$2"
MONTH="${3:-$(date +%Y-%m)}"

if [ -z "$VENDOR" ]; then
  echo "error: vendor name is required"
  echo "usage: ./create-bill-note.sh <vault-root> <vendor> [YYYY-MM]"
  exit 1
fi

TEMPLATE="$VAULT/raw/templates/bill.md"
TARGET="$VAULT/raw/bills/$VENDOR - $MONTH.md"
DATE="$MONTH-01"

if [ -f "$TARGET" ]; then
  echo "error: bill already exists at $TARGET"
  exit 1
fi

if [ ! -f "$TEMPLATE" ]; then
  echo "error: template not found at $TEMPLATE"
  exit 1
fi

sed -e "s/^date:$/date: $DATE/" \
    -e "s/^vendor:$/vendor: $VENDOR/" \
    "$TEMPLATE" > "$TARGET"

echo "created: $TARGET"
