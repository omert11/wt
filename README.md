# wt - Universal Git Worktree Manager

A powerful CLI tool for managing Git worktrees with automatic project setup and Claude Code integration.

## Features

- **Universal Project Support**: Flutter, Rust, npm/yarn/pnpm/bun, Python/Django, Go, Ruby, PHP
- **Automatic Setup**: Runs package manager install after creating worktree
- **Config Sync**: Copies `.vscode`, `.claude`, `.serena`, `.idea` folders to new worktrees
- **Claude Code Integration**: Automatically opens Claude Code in new worktree
- **GitHub PR Workflow**: Create PR, merge, and cleanup with single command

## Installation

### Quick Install

```bash
# Download and install
curl -fsSL https://raw.githubusercontent.com/omert11/wt/main/install.sh | bash
```

### Manual Install

```bash
# Clone the repo
git clone https://github.com/omert11/wt.git

# Copy to local bin
mkdir -p ~/.local/bin
cp wt/wt ~/.local/bin/wt
chmod +x ~/.local/bin/wt

# Add to PATH (add to ~/.zshrc or ~/.bashrc)
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

### Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `wt new <name> [base]` | `n` | Create new worktree from branch (default: main) |
| `wt go <name>` | `g` | Open Claude Code in existing worktree |
| `wt merge [name]` | `m` | Create PR, merge, and cleanup worktree |
| `wt list` | `ls` | List all worktrees |
| `wt status` | `st` | Show status of all worktrees |
| `wt remove <name>` | `rm` | Remove a worktree |
| `wt clean` | - | Remove all worktrees |
| `wt path <name>` | `p` | Print worktree path |
| `wt type` | `t` | Show detected project type |
| `wt help` | `h` | Show help |

### Examples

```bash
# Create a new feature worktree
wt new auth

# Create worktree from specific branch
wt new bugfix develop

# Open Claude in existing worktree
wt go auth

# Complete workflow: PR → merge → cleanup
wt merge auth

# List all worktrees
wt ls

# Check status of all worktrees
wt st
```

## Workflow

### Creating a Feature

```bash
# 1. Create new worktree (auto-opens Claude Code)
wt new my-feature

# 2. Work on your feature...
# Claude Code is now running in the worktree

# 3. When done, merge and cleanup
wt merge my-feature
```

### Worktree Structure

```
your-project/                    # Main repo
../your-project-worktrees/       # Worktrees directory
├── feature-1/                   # Worktree for feature-1
├── feature-2/                   # Worktree for feature-2
└── bugfix/                      # Worktree for bugfix
```

## Configuration

wt uses a layered config system:

1. **Default config** - Built into the script
2. **Global config** - `~/.config/wt/config`
3. **Project config** - `.wtconfig` in project root

### Managing Config

```bash
# Show current configuration
wt config

# Edit global config (creates if not exists)
wt config edit
```

### Config Options

```bash
# Folders to copy from main repo to worktree
COPY_FOLDERS=(
    ".vscode"
    ".serena"
    ".claude"
    ".idea"
)

# Files to copy from main repo to worktree
COPY_FILES=(
    ".env"
    ".env.local"
    ".editorconfig"
)

# Worktree directory pattern
WORKTREE_DIR_PATTERN="../{project}-worktrees"

# Branch prefix for new worktrees
BRANCH_PREFIX="feature/"

# Auto-open Claude Code after creating worktree
AUTO_CLAUDE=true

# PR merge method: squash, merge, rebase
PR_MERGE_METHOD="squash"

# Delete branch after merge
PR_DELETE_BRANCH=true

# Auto-confirm merge (skip confirmation prompt)
PR_AUTO_MERGE=false
```

### Project-Specific Config

Create a `.wtconfig` file in your project root to override settings per project:

```bash
# .wtconfig
BRANCH_PREFIX="fix/"
AUTO_CLAUDE=false
```

## Supported Project Types

| Project | Detection | Auto Setup |
|---------|-----------|------------|
| Flutter | `pubspec.yaml` | `flutter pub get` + build_runner |
| Rust | `Cargo.toml` | `cargo fetch` |
| Node.js | `package.json` | npm/yarn/pnpm/bun install |
| Python | `pyproject.toml`, `requirements.txt` | poetry/uv/pip install |
| Go | `go.mod` | `go mod download` |
| Ruby | `Gemfile` | `bundle install` |
| PHP | `composer.json` | `composer install` |

## Requirements

- Git
- [GitHub CLI](https://cli.github.com/) (`gh`) - for merge command
- [Claude Code](https://claude.ai/code) - optional, for auto-open feature

## License

MIT
