#!/bin/bash

set -eu

# Show help
if [[ "$*" == *--help* ]]; then
    cat <<EOF
Usage: git commit-by-claude [--help]

Requirements:
  - git: Version control system
  - claude: Claude AI CLI tool
  - jq: JSON processor
EOF
    exit 0
fi

# Check required commands
echo "Check required external commands..."

for cmd in git claude jq; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf "[ERROR] Required command '%s' not found. Please install it.\n" "$cmd" >&2
        exit 1
    fi
done

echo "=> OK."

echo
echo "Check changes..."
echo "===="

# Ensure we're inside a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not a git repository."
    exit 0
fi

# Print git status
git status

# Check if there are any changes to commit
if [[ -z $(git status --porcelain) ]]; then
    echo "No changes to commit."
    exit 0
fi

echo "===="

# Prepare prompt for Claude to analyze git diff and suggest commit message
echo
echo "Generating commit message by Claude..."

input='Check the diff of the changes and suggest a simple commit message, but print only the body of the commit message.'

# Call Claude AI to generate commit message suggestion
response=$(claude -p "$input" --output-format json)
echo
echo "Claude response:"
echo "$response" | jq

# Check if Claude returned an error
is_error=$(echo "$response" | jq -r '.is_error')

if [[ "$is_error" == "true" ]]; then
    echo "[ERROR] An error occurred while getting commit message from Claude." >&2
    exit 1
fi

# Extract the commit message from Claude's response
message=$(echo "$response" | jq -r '.result')

# Present the suggested commit message to the user
echo
echo "[Ask] Claude Code suggests a commit message:"
echo '```'
echo "$message"
echo '```'
echo "Continue commit? [Y/n]"
read -r -p "> " answer

# Process user's confirmation (empty input defaults to Yes)
if [[ "$answer" =~ ^([Nn]|[Nn][Oo])$ ]]; then
    echo "Exit without commit."
else
    # Stage all changes and commit with the suggested message
    git add .
    git commit -m "$message"
fi
