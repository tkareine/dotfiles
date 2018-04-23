source ~/.bashrc.support
source ~/.bashrc.common

if [[ -n $PS1 ]]; then
    source ~/.bashrc.ps1
    source ~/.bashrc.aliases
fi

[[ -r ~/.bashrc.host ]] && source ~/.bashrc.host
