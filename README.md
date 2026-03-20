# Shell Scripts

## Requirements

- [mise](https://mise.jdx.dev/)

## Usage

### Link scripts in your PATH

You can create symlinks for all scripts in `src/` to a directory in your PATH (default: `~/.local/bin`) and set executable permissions using mise:

```bash
mise run link            # Link to ~/.local/bin (default)
mise run link -- ~/bin   # Link to ~/bin
```

**Note:** To remove symlinks, please delete them manually from the target directory.

### Others

- Show links

    ```bash
    mise run link-ls
    ```

- Remove broken links

    ```bash
    mise run link-rm
    ```
