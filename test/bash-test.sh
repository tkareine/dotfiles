#!/usr/bin/env bash

set -euo pipefail

source test/support/assertions.sh

__clean_shell() {
    env -i \
        TERM="$TERM" \
        HOME="$HOME" \
        SSH_AUTH_SOCK="${SSH_AUTH_SOCK-}" \
        "$SHELL" \
        "$@"
}

test_interactive_login_shell() {
    local stdout
    stdout=$(__clean_shell --login -i -c true 2>&1)
    local status=$?
    [[ $status = 0 ]] || fail_test "error in bash init for interactive login shell"
    assert_equal '' "$stdout"
}

test_interactive_nonlogin_shell() {
    local stdout
    # For now, don't redirect stderr to stdout. Having bash-completion@2
    # installed causes lines similar to the following printed to stderr:
    #
    # bash: warning: setlocale: LC_CTYPE: cannot change locale (): Bad file descriptor
    stdout=$(__clean_shell -i -c true)
    local status=$?
    [[ $status = 0 ]] || fail_test "error in bash init for interactive non-login shell"
    assert_equal '' "$stdout"
}

TEST_SOURCE=$0 source test/support/suite.sh
