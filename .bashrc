source ~/.bashrc.functions
source ~/.bashrc.common

[[ `uname` == Darwin ]] && source ~/.bashrc.darwin

if [[ -n $PS1 ]]; then
    source ~/.bashrc.aliases
    source ~/.bashrc.looks
fi

[[ -r ~/.bashrc.host ]] && source ~/.bashrc.host
