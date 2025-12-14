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
    local status=$?
    [[ $restore_errexit = 0 ]] && set -e
    if [[ $status != 0 ]]; then
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
    local status=$?
    [[ $restore_errexit = 0 ]] && set -e
    if [[ $status = 0 ]]; then
        echo "assert_fail(): succeeded: $cmd" >&2
        return 1
    fi
}

assert_fail_with() {
    (($# < 3)) && echo "assert_fail_with(): expects at least 3 arguments" >&2 && return 2

    local expected_status expected_stderr cmd actual_stderr
    expected_status=$1
    shift
    expected_stderr=$1
    shift
    cmd="$*"

    [[ -z $cmd ]] && echo "assert_fail_with(): empty command" >&2 && return 2

    [[ $- = *e* ]]
    # shellcheck disable=SC2319
    local restore_errexit=$?
    set +e

    actual_stderr=$(eval "$cmd 2>&1 1>/dev/null")
    local actual_status=$?

    [[ $restore_errexit = 0 ]] && set -e

    if [[ $actual_status != "$expected_status" ]]; then
        printf "assert_fail_with(): unexpected exit status %s (should be %s):\ncommand: %s\n" \
            "$actual_status" \
            "$expected_status" \
            "$cmd" \
            >&2
        return 1
    fi
    if [[ $actual_stderr != "$expected_stderr" ]]; then
        printf "assert_fail_with(): unexpected stderr:\nactual:\t\t'%s'\nexpected:\t'%s'\ncommand:\t%s\n" \
            "$actual_stderr" \
            "$expected_stderr" \
            "$cmd" \
            >&2
        return 1
    fi
}

fail_test() {
    echo "fail_test(): $*" >&2
    return 1
}
