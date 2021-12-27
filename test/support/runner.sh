#!/usr/bin/env bash

set -euo pipefail

__run_tests() {
    local test_file
    for test_file in "$@"; do
        (
            printf '# %s\n' "$test_file"
            exec "$SHELL" "$test_file"
        )
    done
}

if (($# < 1)); then
    cat << 'EOF' >&2
No test files to run.

Usage: run-tests.sh file_1 [file_2 ...]
EOF

    exit 2
fi

printf 'SHELL=%s (%s)\n' "$SHELL" "$BASH_VERSION"

__run_tests "$@"
