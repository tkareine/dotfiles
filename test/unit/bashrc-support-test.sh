#!/usr/bin/env bash

set -euo pipefail

source test/support/assertions.sh
source .bashrc-support.sh

test_tk_print_error() {
    local msg
    msg=$(tk_print_error 'foo bar' 'baz' 2>&1)
    assert_equal "$msg" "foo bar baz"
}

test_tk_exit_if_fail_when_ok() {
    local msg
    msg=$(tk_exit_if_fail true 2>&1)
    assert_equal $? 0
    assert_equal "$msg" ""
}

test_tk_exit_if_fail_when_fail() {
    local msg ecode
    set +e
    msg=$(tk_exit_if_fail false 2>&1)
    ecode=$?
    set -e
    assert_equal $ecode 1
    assert_equal "$msg" "failed (1): false"
}

test_tk_join() {
    local ary=(a bb ccc "d dd d")
    assert_equal "$(tk_join , "${ary[@]}")" "a,bb,ccc,d dd d"
}

test_tk_trim() {
    assert_equal "$(tk_trim $' foo bar \t\n')" "foo bar"
}

test_tk_cmd_exist() {
    assert_ok 'tk_cmd_exist echo'
    assert_fail 'tk_cmd_exist nosuch'
}

test_tk_fn_exist() {
    assert_ok 'tk_fn_exist test_tk_fn_exist'
    assert_fail 'tk_fn_exist nosuch'
}

test_tk_version_in_path() {
    assert_equal "$(tk_version_in_path /usr/local/share/node-14)" 14
    assert_equal "$(tk_version_in_path /usr/local/share/node-14.4.5)" 14.4.5
    assert_equal "$(tk_version_in_path /usr/local/share/node-14.4.5/bin)" 14.4.5
    assert_equal "$(tk_version_in_path /usr/local/Cellar/openjdk/17/libexec/openjdk.jdk/Contents/Home)" 17
    assert_equal "$(tk_version_in_path /usr/local/Cellar/openjdk@11/11.0.12/libexec/openjdk.jdk/Contents/Home)" 11.0.12
    assert_equal "$(tk_version_in_path /usr/local)" ''
    assert_equal "$(tk_version_in_path /usr)" ''
    assert_equal "$(tk_version_in_path /)" ''
}

test_tk_bm() {
    local actual
    # shellcheck disable=SC2034
    readarray -t actual < <(tk_bm_num_times=2; tk_bm 'sleep 0.1 && false')
    local exp_lines=(
        $'^[0-9]+\\.[0-9]{3} secs for 2 times run command: sleep 0.1 && false$'
        $'^[0-9]+\\.[0-9]{3} ms/command$'
    )
    [[ ${actual[0]} =~ ${exp_lines[0]} ]] || fail_test "didn't match: ${actual[0]}"
    [[ ${actual[1]} =~ ${exp_lines[1]} ]] || fail_test "didn't match: ${actual[1]}"
}

TEST_SOURCE=$0 source test/support/runner.sh
