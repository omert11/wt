#!/bin/bash
# wt installer

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

printf "${BLUE}Installing wt - Git Worktree Manager${NC}\n"
echo ""

# Create directories
mkdir -p ~/.local/bin

# Download wt script as _wt (internal command)
# Using timestamp to bust GitHub's CDN cache
echo "Downloading wt..."
curl -fsSL "https://raw.githubusercontent.com/omert11/wt/main/wt?t=$(date +%s)" -o ~/.local/bin/_wt
chmod +x ~/.local/bin/_wt

# Download shell wrapper function file with completions
echo "Downloading shell wrapper..."
curl -fsSL "https://raw.githubusercontent.com/omert11/wt/main/wt.sh?t=$(date +%s)" -o ~/.local/bin/wt.sh

# Detect shell config file
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
SOURCE_LINE='[ -f ~/.local/bin/wt.sh ] && source ~/.local/bin/wt.sh'

# Remove old inline function if exists (cleanup from previous installs)
if grep -q "# wt - Git Worktree Manager wrapper" "$SHELL_CONFIG" 2>/dev/null; then
    printf "${YELLOW}Removing old inline function from $SHELL_CONFIG${NC}\n"
    sed -i.bak '/# wt - Git Worktree Manager wrapper/,/^}/d' "$SHELL_CONFIG"
    rm -f "$SHELL_CONFIG.bak"
fi

# Add source line if not exists
if ! grep -q "wt.sh" "$SHELL_CONFIG" 2>/dev/null; then
    # Ensure file ends with newline before appending
    [ -n "$(tail -c 1 "$SHELL_CONFIG" 2>/dev/null)" ] && echo "" >> "$SHELL_CONFIG"
    echo "$SOURCE_LINE" >> "$SHELL_CONFIG"
    printf "${GREEN}Added source line to $SHELL_CONFIG${NC}\n"
else
    printf "${YELLOW}Source line already exists in $SHELL_CONFIG${NC}\n"
fi

# Check PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    if ! grep -q '.local/bin' "$SHELL_CONFIG" 2>/dev/null; then
        [ -n "$(tail -c 1 "$SHELL_CONFIG" 2>/dev/null)" ] && echo "" >> "$SHELL_CONFIG"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_CONFIG"
        printf "${GREEN}Added ~/.local/bin to PATH${NC}\n"
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
