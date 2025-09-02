#!/bin/bash

set -eu

target_dir="${1:-$HOME/.local/bin}"
broken_links=$(find "$target_dir" -xtype l)
echo "$broken_links"

if [ -z "$broken_links" ]; then
    echo "No broken symlinks found in $target_dir."
    exit 0
fi

echo "Removing broken symlinks in $target_dir..."
find "$target_dir" -xtype l -delete

echo "Done!"
