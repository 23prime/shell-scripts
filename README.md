# Shell Scripts

## Requirements

- [Taskfile](https://taskfile.dev/)
- [mise](https://mise.jdx.dev/)

## Usage

### Link scripts in your PATH

You can create symlinks for all scripts in `src/` to a directory in your PATH (default: `~/.local/bin`) and set executable permissions using Taskfile:

```bash
task link            # Link to ~/.local/bin (default)
task link -- ~/bin   # Link to ~/bin
```

**Note:** To remove symlinks, please delete them manually from the target directory.
