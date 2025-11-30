# wt - Git Worktree Manager

A shell tool for managing Git worktrees with automatic project setup and navigation.

## Architecture

```
~/.local/bin/_wt      # Main bash script (all logic)
~/.local/bin/wt.sh    # Shell wrapper function + completions
```

The wrapper function is needed because shell scripts cannot change the parent shell's directory. Commands like `go`, `claude`, and `top` output shell commands that get `eval`'d by the wrapper.

## Key Files

| File | Purpose |
|------|---------|
| `wt` | Main script with all commands |
| `install.sh` | Installer that sets up _wt, wt.sh, and shell config |
| `config.example` | Example configuration file |

## Commands

| Command | Output | Needs Wrapper |
|---------|--------|---------------|
| `new` | Creates worktree + runs setup | No |
| `go <name>` | `cd '/path'` | Yes |
| `claude [name]` | `cd '/path' && claude` | Yes |
| `top` | `cd '/main/repo'` | Yes |
| `list` | Prints worktree list | No |
| `remove` | Removes worktree | No |
| `merge` | PR + merge + cleanup | No |
| `status` | Shows all worktree status | No |
| `config` | Manages configuration | No |

## Configuration

Layered config system (later overrides earlier):
1. Defaults in script
2. `~/.config/wt/config` (global)
3. `.wtconfig` (project-local)

Key settings:
- `COPY_FOLDERS` - Folders to copy to new worktrees
- `COPY_FILES` - Files to copy to new worktrees
- `WORKTREE_DIR_PATTERN` - Where to create worktrees
- `BRANCH_PREFIX` - Prefix for new branches
- `PR_MERGE_METHOD` - squash/merge/rebase

## Project Detection

Detects project type from files:
- `pubspec.yaml` → Flutter
- `Cargo.toml` → Rust
- `package.json` → Node.js
- `pyproject.toml` / `requirements.txt` → Python
- `go.mod` → Go
- `Gemfile` → Ruby
- `composer.json` → PHP

## Shell Wrapper Logic

```bash
wt() {
    if [[ "$1" == "go" || "$1" == "g" || "$1" == "claude" || "$1" == "c" || "$1" == "top" ]]; then
        local cmd
        cmd=$(_wt "$@")
        if [[ $? -eq 0 && -n "$cmd" ]]; then
            eval "$cmd"
        fi
    else
        _wt "$@"
    fi
}
```

## Completion

Auto-completion for zsh and bash:
- Commands with descriptions
- Worktree names for relevant commands
- Config subcommands

## Development Notes

- Errors go to stderr (`>&2`) for commands that output shell code
- `printf` instead of `echo -e` for cross-shell compatibility
- Check newline before appending to shell config files
- Cache-bust GitHub raw URLs with timestamp query param
