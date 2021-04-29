#!/usr/bin/env bash

set -euo pipefail

assert_equal() {
    [[ $# != 2 ]] && echo "assert_equal(): expects two arguments" >&2 && return 2
    local actual=$1
    local expected=$2
    if [[ $actual != "$expected" ]]; then
        printf "assert_equal(): were not equal:\nactual:\t\t'%s'\nexpected:\t'%s'\n" "$actual" "$expected" >&2
        return 1
    fi
}

assert_ok() {
    local cmd="$*"
    [[ -z $cmd ]] && echo "assert_ok(): empty command" >&2 && return 2
    [[ $- = *e* ]]
    local restore_errexit=$?
    set +e
    eval "$cmd" >/dev/null
    local result=$?
    [[ $restore_errexit = 0 ]] && set -e
    if [[ $result != 0 ]]; then
        echo "assert_ok(): failed: $cmd" >&2
        return 1
    fi
}

assert_fail() {
    local cmd="$*"
    [[ -z $cmd ]] && echo "assert_fail(): empty command" >&2 && return 2
    [[ $- = *e* ]]
    local restore_errexit=$?
    set +e
    eval "$cmd" >/dev/null
    local result=$?
    [[ $restore_errexit = 0 ]] && set -e
    if [[ $result = 0 ]]; then
        echo "assert_fail(): succeeded: $cmd" >&2
        return 1
    fi
}
