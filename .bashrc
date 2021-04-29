# shellcheck shell=bash

# To quickly benchmark Bash startup time:
#
# * for interactive login shell: `time bash --login -i -c true`
# * for interactive shell: `time bash -i -c true`

# optimization: cache current uname
# shellcheck disable=SC2034
tk__uname=$(uname)

source ~/.bashrc.support
source ~/.bashrc.common

[[ -r ~/.bashrc.host ]] && source ~/.bashrc.host

[[ -n $PS1 ]] && source ~/.bashrc.ps1

true  # ensure last command is successful
