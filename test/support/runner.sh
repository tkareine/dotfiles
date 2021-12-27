#!/usr/bin/env bash

set -euo pipefail

__run_tests() {
    local test_file
    local exit_status=0

    for test_file in "$@"; do
        printf '\n# %s\n' "$test_file"
        (
            exec "$SHELL" "$test_file"
        ) || ((exit_status += 1))
    done

    return "$exit_status"
}

printf 'Using SHELL=%s (%s)\n' "$SHELL" "$BASH_VERSION"

__run_tests "$@"
