#!/bin/bash
# scaffold-project.sh
# Creates language-appropriate project folder structure.
# Usage: ./scaffold-project.sh <project-root> <language>
# Language: python | bash | go
# Note: only creates folders — files (AGENTS.md, pyproject.toml, etc.) are created by the AI workflow.

PROJECT="${1:-.}"
LANGUAGE="${2:-python}"

if [ -z "$1" ]; then
  echo "error: project root path is required"
  echo "usage: ./scaffold-project.sh <project-root> <language>"
  echo "language: python | bash | go"
  exit 1
fi

case "$LANGUAGE" in
  python)
    # Derive package name: kebab-case → snake_case
    PACKAGE=$(basename "$PROJECT" | tr '-' '_' | tr '[:upper:]' '[:lower:]')
    mkdir -p \
      "$PROJECT/src/$PACKAGE" \
      "$PROJECT/tests"
    ;;

  bash)
    mkdir -p \
      "$PROJECT/bin" \
      "$PROJECT/lib" \
      "$PROJECT/tests"
    ;;

  go)
    mkdir -p \
      "$PROJECT/cmd" \
      "$PROJECT/internal" \
      "$PROJECT/tests"
    ;;

  *)
    echo "warning: unknown language '$LANGUAGE' — creating generic structure"
    mkdir -p \
      "$PROJECT/src" \
      "$PROJECT/tests"
    ;;
esac

echo "scaffolded: $PROJECT (language: $LANGUAGE)"
echo ""
echo "folders created:"
find "$PROJECT" -type d | sort | sed "s|$PROJECT/||" | grep -v "^\.$"
