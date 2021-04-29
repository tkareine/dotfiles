#!/usr/bin/env bash

set -euo pipefail

cd "${0%/*}" || exit 2

source ../support/assertions.sh
source ../../.bashrc.support

test_tk_join() {
    local ary=(a bb ccc "d dd d")
    assert_equal "$(tk_join , "${ary[@]}")" "a,bb,ccc,d dd d"
}

test_tk_join

test_tk_trim() {
    assert_equal "$(tk_trim $' foo bar \t\n')" "foo bar"
}

test_tk_trim

test_tk_cmd_exist() {
    assert_ok 'tk_cmd_exist echo'
    assert_fail 'tk_cmd_exist nosuch'
}

test_tk_cmd_exist

test_tk_fn_exist() {
    assert_ok 'tk_fn_exist test_tk_fn_exist'
    assert_fail 'tk_fn_exist nosuch'
}

test_tk_fn_exist

test_tk_bm() {
    local actual
    readarray -t actual < <(tk_bm_num_times=2; tk_bm 'sleep 0.1 && false')
    local exp_lines=(
        $'^[0-9]+\\.[0-9]{3} secs for 2 times eval: sleep 0.1 && false$'
        $'^[0-9]+\\.[0-9]{3} ms/eval$'
    )
    [[ ${actual[0]} =~ ${exp_lines[0]} ]] || fail_test "didn't match: ${actual[0]}"
    [[ ${actual[1]} =~ ${exp_lines[1]} ]] || fail_test "didn't match: ${actual[1]}"
}

test_tk_bm
