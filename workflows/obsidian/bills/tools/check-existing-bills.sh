#!/bin/bash
# check-existing-bills.sh
# Lists bill notes that already exist for a given month.
# Usage: ./check-existing-bills.sh <vault-root> [YYYY-MM]
# If month is omitted, defaults to current month.

VAULT="${1:-.}"
MONTH="${2:-$(date +%Y-%m)}"
BILLS_DIR="$VAULT/raw/bills"

if [ ! -d "$BILLS_DIR" ]; then
  echo "error: bills directory not found at $BILLS_DIR"
  exit 1
fi

found=0
for f in "$BILLS_DIR"/*" - $MONTH.md"; do
  if [ -f "$f" ]; then
    basename "$f" | sed "s/ - $MONTH\.md//"
    found=1
  fi
done

if [ "$found" -eq 0 ]; then
  echo "none"
fi
