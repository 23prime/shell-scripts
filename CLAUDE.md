# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a collection of shell scripts (`src/*.sh`) that can be symlinked to a user's PATH for convenient command-line usage. The project uses mise for task automation and tool version management.

## Development Workflow

### Initial Setup

```bash
mise run setup  # Installs all tools via mise
```

### Code Quality Checks

Run all checks before committing:

```bash
mise run check  # Runs all checks: shell, markdown, and GitHub Actions
```

Individual checks:

```bash
mise run sh-check    # Format (shfmt) + lint (shellcheck) shell scripts
mise run md-check    # Fix and lint Markdown with markdownlint-cli2
mise run gh-check    # Validate GitHub Actions workflows with actionlint
mise run spell-check # Check spelling with cspell
```

### Formatting and Linting

Shell scripts:

```bash
mise run sh-fix  # Format with shfmt (4 spaces, write mode)
mise run sh-check  # Lint all scripts in src/ with shellcheck
```

## Code Standards

### Shell Scripts

- Indentation: 4 spaces (enforced by .editorconfig and shfmt)
- Location: All user-facing scripts go in `src/`
- Tool scripts: Internal tooling goes in `tools/`
- Shell check compliance: All scripts must pass shellcheck
- Format: Must be formatted with `shfmt -i 4 -w .`

### Other Files

- YAML: 2-space indentation
- Markdown: Must pass markdownlint validation
- All files: UTF-8, LF line endings, trailing newline, no trailing whitespace

## Architecture

### Task Organization

Tasks are defined in `mise.toml`:

- `setup` - Install all tools
- `check` - Run all checks
- `fix` - Fix all auto-fixable issues
- `sh-fix` / `sh-check` - Shell script formatting and linting
- `md-fix` / `md-check` - Markdown linting
- `gh-check` - GitHub Actions validation
- `spell-check` - Spell checking
- `link` / `link-ls` / `link-rm` - Symlink management

### Symlink System

The `tools/link.sh` script creates symlinks from `src/*.sh` to a target directory (default: `~/.local/bin`), removing the `.sh` extension. This allows scripts to be called directly by name.

```bash
mise run link              # Link to ~/.local/bin
mise run link -- ~/bin     # Link to custom directory
mise run link-ls                  # List existing symlinks
mise run link-rm                  # Remove broken symlinks
```

## Tool Versions

All development tools are managed via mise (see `mise.toml`):

- shellcheck (latest)
- shfmt 3
- markdownlint-cli2 (latest)
- actionlint (latest)
- lefthook (latest)
- cspell (latest)
