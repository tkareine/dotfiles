# To quickly benchmark bash startup time, run `time bash -i -c true`.

# optimization: cache current uname
tk__uname=$(uname)

source ~/.bashrc.support
source ~/.bashrc.common

[[ -r ~/.bashrc.host ]] && source ~/.bashrc.host

[[ -n $PS1 ]] && source ~/.bashrc.ps1

true  # ensure last command is successful
