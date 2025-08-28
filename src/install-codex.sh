#!/bin/bash

set -eu

# Show help
if [[ "$*" == *--help* ]]; then
    cat <<EOF
install-codex: Installs the OpenAI Codex CLI binary on x86_64 Linux systems.

Usage: install-codex [--help]

Requirements:
    - gh: GitHub CLI (for fetching release information)
    - zstd: Compression tool (for decompressing .zst files)
    - jq: JSON processor (for parsing GitHub API responses)
EOF
    exit 0
fi

# Check if running on x86 Linux
arch=$(uname -m)
os=$(uname -s)

if [[ "$arch" != "x86_64" || "$os" != "Linux" ]]; then
    echo "[ERROR] This script is for x86_64 Linux only." >&2
    exit 1
fi

# Check required commands
for cmd in gh zstd jq; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf "[ERROR] Required command '%s' not found. Please install it.\n" "$cmd" >&2
        exit 1
    fi
done

# Check and print releases
gh release list --repo openai/codex --limit 5 --exclude-drafts --exclude-pre-releases
echo "..."

# Get latest version
latest_version=$(gh release list --repo openai/codex --limit 1 --exclude-drafts --exclude-pre-releases | cut -f 1)
echo "Latest version => $latest_version"

target_version=$latest_version

# Ask to continue
echo "Continue to install Codex CLI (version: $target_version)? [Y/n]"
read -r -p "> " answer

if [[ "$answer" =~ ^([Nn]|[Nn][Oo])$ ]]; then
    echo "Exit without install."
    exit
fi

# Get download URL
download_url=$(curl -s 'https://api.github.com/repos/openai/codex/releases?per_page=1&page=1' | jq -r '.[0].assets[] | select(.name== "codex-x86_64-unknown-linux-musl.zst") | .browser_download_url')
echo
echo "Download URL:"
echo "$download_url"

# Config download path
download_dir="/tmp"
file_name="codex-x86_64-unknown-linux-musl.zst"
download_path="$download_dir/$file_name"

# Download
echo
echo "Downloading..."
curl -s -L -o "$download_path" "$download_url"

# Config as command
cmd_dir="$HOME/.local/bin"
cmd_name="codex"
cmd_path="$cmd_dir/$cmd_name"

echo "Installing..."

# Decompress and enable to execute
zstd -f -q -d "$download_path" -o "$cmd_path"
chmod +x "$cmd_path"

# Check
echo
echo "Check installed version:"
$cmd_name --version

# Clean
echo
echo "Remove tmp file..."
rm -f "$download_path"

echo
echo "Done!"
