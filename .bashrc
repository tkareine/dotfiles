source ~/.bashrc.functions
source ~/.bashrc.common
[[ `uname` == Darwin ]] && source ~/.bashrc.darwin
[[ -r ~/.bashrc.host ]] && source ~/.bashrc.host
[[ -n $PS1 ]] && source ~/.bashrc.aliases
[[ -n $PS1 ]] && source ~/.bashrc.prompt
