# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a collection of shell scripts (`src/*.sh`) that can be symlinked to a user's PATH for convenient command-line usage. The project uses Taskfile for task automation and mise for tool version management.

## Development Workflow

### Initial Setup

```bash
task setup  # Installs all tools via mise (trusts and installs from mise.toml)
```

### Code Quality Checks

Run all checks before committing:

```bash
task check  # Runs all checks: shell, yaml, json, markdown, and GitHub Actions
```

Individual checks:

```bash
task sh:check   # Format (shfmt) + lint (shellcheck) shell scripts
task yml:check  # Lint YAML files with yamllint
task json:fmt   # Format and lint JSON with biome
task md:check   # Fix and lint Markdown with markdownlint
task gh:check   # Validate GitHub Actions workflows with actionlint
```

### Formatting and Linting

Shell scripts:

```bash
task sh:fmt   # Format with shfmt (4 spaces, write mode)
task sh:lint  # Lint all scripts in src/ with shellcheck
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
- JSON: 2-space indentation, formatted with biome
- Markdown: Must pass markdownlint validation
- All files: UTF-8, LF line endings, trailing newline, no trailing whitespace

## Architecture

### Task Organization

Taskfile is modular with domain-specific task files in `tasks/`:

- `tasks/ShellTasks.yml` - Shell script formatting and linting
- `tasks/LinkTasks.yml` - Symlink management (create, list, remove)
- `tasks/YamlTasks.yml` - YAML linting
- `tasks/JsonTasks.yml` - JSON formatting/linting
- `tasks/MarkdownTasks.yml` - Markdown linting
- `tasks/GitHubTasks.yml` - GitHub Actions validation
- `tasks/MiseTasks.yml` - Tool installation and version display

Tasks are namespaced (e.g., `task sh:lint`, `task link:create`).

### Symlink System

The `tools/link.sh` script creates symlinks from `src/*.sh` to a target directory (default: `~/.local/bin`), removing the `.sh` extension. This allows scripts to be called directly by name.

```bash
task link:create              # Link to ~/.local/bin
task link:create -- ~/bin     # Link to custom directory
task link:ls                  # List existing symlinks
task link:rm                  # Remove broken symlinks
```

## Tool Versions

All development tools are managed via mise (see `mise.toml`):

- shellcheck 0.10
- shfmt 3
- yamllint (latest)
- markdownlint-cli (latest, via npm)
- biome (latest)
- actionlint (latest)

Check installed versions with `task mise:versions`.
