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

# Create shell wrapper function file with completions
echo "Creating shell wrapper..."
cat > ~/.local/bin/wt.sh << 'FUNC'
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

# Get list of worktree names for completion
_wt_list_worktrees() {
    local worktree_base
    worktree_base=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -z "$worktree_base" ]]; then
        return
    fi
    local project_name=$(basename "$worktree_base")
    local wt_dir="../${project_name}-worktrees"
    if [[ -d "$wt_dir" ]]; then
        ls -1 "$wt_dir" 2>/dev/null
    fi
}

# Zsh completion
if [[ -n "$ZSH_VERSION" ]]; then
    _wt_completions() {
        local -a commands worktree_cmds
        commands=(
            'new:Create new worktree'
            'n:Create new worktree (alias)'
            'go:Change directory to worktree'
            'g:Change directory to worktree (alias)'
            'claude:Open Claude Code in worktree'
            'c:Open Claude Code in worktree (alias)'
            'list:List all worktrees'
            'ls:List all worktrees (alias)'
            'remove:Remove a worktree'
            'rm:Remove a worktree (alias)'
            'clean:Remove all worktrees'
            'path:Print worktree path'
            'p:Print worktree path (alias)'
            'status:Show status of all worktrees'
            'st:Show status of all worktrees (alias)'
            'type:Show detected project type'
            't:Show detected project type (alias)'
            'merge:Create PR, merge, and cleanup'
            'm:Create PR, merge, and cleanup (alias)'
            'config:Show or edit configuration'
            'cfg:Show or edit configuration (alias)'
            'help:Show help'
            'h:Show help (alias)'
        )
        worktree_cmds=(go g claude c remove rm path p merge m)

        if (( CURRENT == 2 )); then
            _describe -t commands 'wt commands' commands
        elif (( CURRENT == 3 )); then
            if [[ ${worktree_cmds[(ie)$words[2]]} -le ${#worktree_cmds} ]]; then
                local -a worktrees
                worktrees=(${(f)"$(_wt_list_worktrees)"})
                _describe -t worktrees 'worktrees' worktrees
            elif [[ "$words[2]" == "config" || "$words[2]" == "cfg" ]]; then
                local -a config_opts
                config_opts=('show:Show configuration' 'edit:Edit configuration' 'path:Print config path')
                _describe -t config 'config options' config_opts
            fi
        fi
    }
    compdef _wt_completions wt

# Bash completion
elif [[ -n "$BASH_VERSION" ]]; then
    _wt_completions() {
        local cur prev commands worktree_cmds
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        commands="new n go g claude c list ls remove rm clean path p status st type t merge m config cfg help h"
        worktree_cmds="go g claude c remove rm path p merge m"

        if [[ ${COMP_CWORD} -eq 1 ]]; then
            COMPREPLY=($(compgen -W "$commands" -- "$cur"))
        elif [[ ${COMP_CWORD} -eq 2 ]]; then
            if [[ " $worktree_cmds " =~ " $prev " ]]; then
                local worktrees=$(_wt_list_worktrees)
                COMPREPLY=($(compgen -W "$worktrees" -- "$cur"))
            elif [[ "$prev" == "config" || "$prev" == "cfg" ]]; then
                COMPREPLY=($(compgen -W "show edit path" -- "$cur"))
            fi
        fi
    }
    complete -F _wt_completions wt
fi
FUNC

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
