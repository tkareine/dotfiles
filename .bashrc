#!/usr/bin/env bash

# To quickly benchmark Bash startup time:
#
# * for interactive login shell: `time bash --login -i -c true`
# * for interactive shell: `time bash -i -c true`

source ~/.bashrc-support.sh
source ~/.bashrc-common.sh

[[ -n $PS1 ]] && source ~/.bashrc-ps1.sh

[[ -r ~/.bashrc-host.sh ]] && source ~/.bashrc-host.sh

true # ensure last command is successful
