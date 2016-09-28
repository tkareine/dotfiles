source ~/.bashrc.functions
source ~/.bashrc.common

[[ `uname` == "Darwin" ]] && source ~/.bashrc.darwin

if [[ -n $PS1 ]]; then
    source ~/.bashrc.aliases
    source ~/.bashrc.looks

    [[ `uname` == "Darwin" ]] && source ~/.iterm2_shell_integration.bash
fi

[[ -r ~/.bashrc.host ]] && source ~/.bashrc.host
[[ -r ~/.bashrc.secret ]] && source ~/.bashrc.secret
