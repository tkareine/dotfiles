# To quickly benchmark bash startup time, run `time bash -i -c true`.

source ~/.bashrc.support
source ~/.bashrc.common

[[ -n $PS1 ]] && source ~/.bashrc.ps1

[[ -r ~/.bashrc.host ]] && source ~/.bashrc.host

true  # ensure last command is successful
