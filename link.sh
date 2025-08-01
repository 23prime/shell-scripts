#!/bin/bash

set -eu

target_dir="${1:-$HOME/.local/bin}"

for f in src/*.sh; do
    name="$(basename "$f" .sh)"
    link_path="$target_dir/$name"

    ln -sf "$(pwd)/$f" "$link_path"
    chmod +x "$link_path"

    echo "Created symlink for $name.sh to $link_path"
done

echo "Done!"
