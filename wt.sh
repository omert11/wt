# wt - Git Worktree Manager wrapper
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
            'top:Go to main repo directory'
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
            'init:Initialize wt for this project'
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
        commands="new n go g claude c top list ls remove rm clean path p status st type t merge m init config cfg help h"
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
