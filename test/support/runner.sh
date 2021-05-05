#!/usr/bin/env bash

set -euo pipefail

if [[ -z ${TEST_SOURCE:-} ]]; then
    cat << 'EOF' >&2
No TEST_SOURCE set.

Usage: TEST_SOURCE=$0 source runner.sh
EOF

    exit 2
fi

__find_test_fns() {
    grep -E '^test_[a-z0-9_]+ *\(\)' "$1" | sed 's/[^a-z0-9_]*//g' | xargs
}

__run_tests() {
    local test_fn test_fns
    test_fns=$(__find_test_fns "$TEST_SOURCE")
    for test_fn in $test_fns; do
        echo "- $test_fn"
        "$test_fn"
    done
}

__run_tests
