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
    __clean_shell --login -i -c true || fail_test "error in bash init for interactive login shell"
}

test_interactive_nonlogin_shell() {
    __clean_shell -i -c true || fail_test "error in bash init for interactive non-login shell"
}

TEST_SOURCE=$0 source test/support/suite.sh
