#!/bin/bash
# wt installer

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

printf "${BLUE}Installing wt - Git Worktree Manager${NC}\n"
echo ""

# Create bin directory
mkdir -p ~/.local/bin

# Download wt script as _wt (internal command)
# Using timestamp to bust GitHub's CDN cache
echo "Downloading wt..."
curl -fsSL "https://raw.githubusercontent.com/omert11/wt/main/wt?t=$(date +%s)" -o ~/.local/bin/_wt

# Make executable
chmod +x ~/.local/bin/_wt

# Shell function to add
SHELL_FUNCTION='
# wt - Git Worktree Manager wrapper
wt() {
    if [[ "$1" == "go" || "$1" == "g" ]]; then
        local cmd
        cmd=$(_wt "$@")
        if [[ $? -eq 0 && -n "$cmd" ]]; then
            eval "$cmd"
        fi
    else
        _wt "$@"
    fi
}
'

# Detect shell and config file
detect_shell_config() {
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        echo "$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == *"bash"* ]]; then
        if [[ -f "$HOME/.bashrc" ]]; then
            echo "$HOME/.bashrc"
        else
            echo "$HOME/.bash_profile"
        fi
    else
        echo "$HOME/.profile"
    fi
}

SHELL_CONFIG=$(detect_shell_config)

# Check if PATH includes ~/.local/bin
PATH_EXPORT='export PATH="$HOME/.local/bin:$PATH"'

# Check if already installed
if grep -q "wt - Git Worktree Manager wrapper" "$SHELL_CONFIG" 2>/dev/null; then
    printf "${YELLOW}Shell function already exists in $SHELL_CONFIG${NC}\n"
else
    echo "" >> "$SHELL_CONFIG"
    echo "$SHELL_FUNCTION" >> "$SHELL_CONFIG"
    printf "${GREEN}Added wt function to $SHELL_CONFIG${NC}\n"
fi

# Check PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    if ! grep -q '.local/bin' "$SHELL_CONFIG" 2>/dev/null; then
        echo "$PATH_EXPORT" >> "$SHELL_CONFIG"
        printf "${GREEN}Added ~/.local/bin to PATH in $SHELL_CONFIG${NC}\n"
    fi
fi

echo ""
printf "${GREEN}wt installed successfully!${NC}\n"
echo ""
printf "${YELLOW}To activate now, run:${NC}\n"
echo "  source $SHELL_CONFIG"
echo ""
echo "Or restart your terminal."
echo ""
echo "Run 'wt help' to get started."
