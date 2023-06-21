#!/usr/bin/env bash

# To quickly benchmark Bash startup time:
#
# * for interactive login shell: `time bash --login -i -c true`
# * for interactive shell: `time bash -i -c true`

# Optimization: cache current operating system kernel and machine
# hardware names
#
# shellcheck disable=SC2034
tk__uname=$(uname -s -m)

source ~/.bashrc-support.sh
source ~/.bashrc-common.sh

[[ -r ~/.bashrc-host.sh ]] && source ~/.bashrc-host.sh

[[ -n $PS1 ]] && source ~/.bashrc-ps1.sh

true  # ensure last command is successful
