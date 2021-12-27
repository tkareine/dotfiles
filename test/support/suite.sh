#!/usr/bin/env bash

set -euo pipefail

if [[ -z ${TEST_SOURCE:-} ]]; then
    cat << 'EOF' >&2
No TEST_SOURCE set.

Usage: TEST_SOURCE=$0 source run-test-suite.sh
EOF

    exit 3
fi

__collect_test_suite_fns() {
    grep -E '^test_[a-z0-9_]+ *\(\)' "$1" | sed 's/[^a-z0-9_]*//g' | xargs
}

__run_test_suite() {
    local test_fn test_fns
    test_fns=$(__collect_test_suite_fns "$TEST_SOURCE")
    for test_fn in $test_fns; do
        printf -- '- %s\n' "$test_fn"
        "$test_fn"
    done
}

__run_test_suite
