#!/bin/bash
# init-git.sh
# Initializes a git repo, creates a language-appropriate .gitignore, and makes the initial commit.
# Usage: ./init-git.sh <project-root> <language>
# Language: python | bash | go (optional, defaults to generic)

PROJECT="${1:-.}"
LANGUAGE="${2:-generic}"

if [ -z "$1" ]; then
  echo "error: project root path is required"
  echo "usage: ./init-git.sh <project-root> <language>"
  exit 1
fi

cd "$PROJECT" || exit 1

# --- .gitignore ---
case "$LANGUAGE" in
  python)
    cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*.pyo
*.pyd
.Python
*.egg-info/
dist/
build/
.eggs/

# uv / virtual environments
.venv/
.env
*.env

# pytest
.pytest_cache/
.coverage
htmlcov/

# editors
.DS_Store
.idea/
.vscode/
*.swp
EOF
    ;;

  go)
    cat > .gitignore << 'EOF'
# Go binaries
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test output
*.test
*.out

# Go workspace
go.work
go.work.sum

# editors
.DS_Store
.idea/
.vscode/
*.swp
EOF
    ;;

  bash)
    cat > .gitignore << 'EOF'
# Bash / shell
*.log
tmp/
.env

# editors
.DS_Store
.idea/
.vscode/
*.swp
EOF
    ;;

  *)
    cat > .gitignore << 'EOF'
# General
*.log
tmp/
.env
.DS_Store
.idea/
.vscode/
*.swp
EOF
    ;;
esac

# --- git init and initial commit ---
git init
git add .
git commit -m "initial scaffold"

echo ""
echo "git initialized: $PROJECT"
echo "initial commit created"
