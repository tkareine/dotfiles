source ~/.bashrc.support
source ~/.bashrc.common

if [[ -n $PS1 ]]; then
    source ~/.bashrc.ps1
    source ~/.bashrc.aliases

    [[ $(uname) == "Darwin" ]] && source ~/.iterm2_shell_integration.bash
fi

[[ -r ~/.bashrc.host ]] && source ~/.bashrc.host
