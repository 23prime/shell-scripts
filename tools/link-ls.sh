#!/bin/bash

set -eu

target_dir="${1:-$HOME/.local/bin}"
find "$target_dir" -type l
