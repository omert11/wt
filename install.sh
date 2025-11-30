#!/bin/bash
# wt installer

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Installing wt - Git Worktree Manager${NC}"
echo ""

# Create bin directory
mkdir -p ~/.local/bin

# Download wt
echo "Downloading wt..."
curl -fsSL https://raw.githubusercontent.com/omert11/wt/refs/heads/main/wt -o ~/.local/bin/wt

# Make executable
chmod +x ~/.local/bin/wt

# Check PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo ""
    echo -e "${BLUE}Add this to your ~/.zshrc or ~/.bashrc:${NC}"
    echo 'export PATH="$HOME/.local/bin:$PATH"'
    echo ""
fi

echo -e "${GREEN}wt installed successfully!${NC}"
echo ""
echo "Run 'wt help' to get started."
