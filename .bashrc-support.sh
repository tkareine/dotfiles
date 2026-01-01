#!/usr/bin/env bash

tk_print_error() {
    echo "$*" >&2
}

tk_exit_if_fail() {
    local cmd=$*
    $cmd
    local status=$?
    if [[ $status -ne 0 ]]; then
        tk_print_error "failed ($status): $cmd"
        exit $status
    fi
    return $status
}

# Usage:
#   ary=(a bb ccc)
#   $(tk_join , "${ary[@]}")
#   => "a,bb,ccc"
tk_join() {
    local IFS="${1:-}"
    shift
    echo "$*"
}

# Usage:
#   tk_trim $' foo bar \t\n'
#   => "foo bar"
tk_trim() {
    # Adapted from
    # https://github.com/dylanaraps/pure-bash-bible#trim-leading-and-trailing-white-space-from-string
    local tmp=${1:-}
    tmp=${tmp#"${tmp%%[![:space:]]*}"}
    tmp=${tmp%"${tmp##*[![:space:]]}"}
    printf '%s\n' "$tmp"
}

tk_cmd_exist() {
    [[ -z ${1:-} ]] && tk_print_error "tk_cmd_exist(): expects command name as the parameter" && return 1
    command -v "$1" &>/dev/null
}

tk_fn_exist() {
    [[ -z ${1:-} ]] && tk_print_error "tk_fn_exist(): expects function name as the parameter" && return 1
    [[ $(type -t "$1") == "function" ]]
}

tk_is_login_shell() {
    shopt -q login_shell
}

tk_version_in_path() {
    [[ -z ${1:-} ]] && tk_print_error "tk_version_in_path(): expects path as the parameter" && return 1
    if [[ $1 =~ [/-]([[:digit:]]+(\.[[:digit:]]+)*) ]]; then
        echo "${BASH_REMATCH[1]}"
    fi
}

: "${tk_bm_num_iterations:=1000}"
: "${tk_bm_num_warmups:=100}"

tk_bm() {
    if [[ $# = 0 ]]; then
        cat <<EOF
Tiny shell function to benchmark the execution time of a command within
the shell itself. Intended for measuring the latencies of shell
commands.

Usage:

  tk_bm true                      Measure baseline latency for comparison
  tk_bm whoami                    Benchmark a command (here, \`whoami\`)
  tk_bm '[[ \$UID = 0 ]]'          Benchmark a shell command
  tk_bm 'eval "\$PROMPT_COMMAND"'  Benchmark your shell prompt

Use the following shell variables to control benchmarking:

  tk_bm_num_iterations  Number of benchmark iterations (currently $tk_bm_num_iterations)
  tk_bm_num_warmups     Number of warmup iterations (currently $tk_bm_num_warmups)

Depends on \`bc(1)\` to be installed.
EOF
        return 2
    fi

    local num_iterations=${tk_bm_num_iterations:-1000}
    local num_warmups=${tk_bm_num_warmups:-100}
    local TIMEFORMAT=%6R
    local cmd="$*"

    eval "__tk_bm_cmd() { { $cmd; } &>/dev/null; }"

    local warmup_secs iterations_secs per_iteration_ms
    declare -a bm_lines

    readarray -n 2 -t bm_lines < <({
        if ((num_warmups > 0)); then
            time for ((i = 0; i < num_warmups; i += 1)); do __tk_bm_cmd; done || true
        fi

        time for ((i = 0; i < num_iterations; i += 1)); do __tk_bm_cmd; done || true
    } 2>&1)

    if ((num_warmups > 0)); then
        warmup_secs=${bm_lines[0]}
        iterations_secs=${bm_lines[1]}

        printf 'warmup for %.3f secs (%d times)\n' \
            "$warmup_secs" \
            "$num_warmups" \
            >&2
    else
        iterations_secs=${bm_lines[0]}
    fi

    per_iteration_ms=$(printf "scale=10\n(%s / %s) * 1000\n" "$iterations_secs" "$num_iterations" | bc)

    printf 'run command for %.3f secs (%d times): %s\nmean %.3f ms\n' \
        "$iterations_secs" \
        "$num_iterations" \
        "$cmd" \
        "$per_iteration_ms"

    unset __tk_bm_cmd
}
