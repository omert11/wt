# wt - Universal Git Worktree Manager

A powerful CLI tool for managing Git worktrees with automatic project setup.

## Features

- **Universal Project Support**: Flutter, Rust, npm/yarn/pnpm/bun, Python/Django, Go, Ruby, PHP
- **Automatic Setup**: Runs package manager install after creating worktree
- **Config Sync**: Copies `.vscode`, `.claude`, `.serena`, `.idea` folders to new worktrees
- **Quick Navigation**: `wt go <name>` instantly changes directory to worktree
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
cd wt

# Copy script to local bin
mkdir -p ~/.local/bin
cp wt ~/.local/bin/_wt
chmod +x ~/.local/bin/_wt

# Create shell wrapper function
cat > ~/.local/bin/wt.sh << 'EOF'
# wt - Git Worktree Manager wrapper
wt() {
    if [[ "$1" == "go" || "$1" == "g" || "$1" == "claude" || "$1" == "c" ]]; then
        local cmd
        cmd=$(_wt "$@")
        if [[ $? -eq 0 && -n "$cmd" ]]; then
            eval "$cmd"
        fi
    else
        _wt "$@"
    fi
}
EOF

# Add to shell config (~/.zshrc or ~/.bashrc)
echo '[ -f ~/.local/bin/wt.sh ] && source ~/.local/bin/wt.sh' >> ~/.zshrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

# Reload shell
source ~/.zshrc
```

## Usage

### Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `wt new <name> [base]` | `n` | Create new worktree from branch (default: main) |
| `wt go <name>` | `g` | Change directory to worktree |
| `wt claude [name]` | `c` | Open Claude Code in worktree |
| `wt top` | - | Go to main repo directory |
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

# Go to existing worktree
wt go auth

# Open Claude Code in worktree
wt claude auth

# Go back to main repo
wt top

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
# 1. Create new worktree
wt new my-feature

# 2. Go to the worktree
wt go my-feature

# 3. Work on your feature...

# 4. When done, merge and cleanup
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
PR_MERGE_METHOD="merge"
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

## License

MIT
