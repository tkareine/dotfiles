source ~/.bashrc.functions
source ~/.bashrc.common
[[ `uname` == Darwin ]] && source ~/.bashrc.darwin
[[ -n $PS1 ]] && source ~/.bashrc.aliases
[[ -n $PS1 ]] && source ~/.bashrc.looks
[[ -r ~/.bashrc.host ]] && source ~/.bashrc.host
