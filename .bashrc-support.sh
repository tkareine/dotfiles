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
    local IFS="$1"
    shift
    echo "$*"
}

# Usage:
#   tk_trim $' foo bar \t\n'
#   => "foo bar"
tk_trim() {
    local tmp=$1
    tmp=${tmp#${tmp%%[![:space:]]*}}
    tmp=${tmp%${tmp##*[![:space:]]}}
    echo -e "$tmp"
}

tk_cmd_exist() {
    [[ -z $1 ]] && tk_print_error "tk_cmd_exist(): expects command name as the parameter" && return 1
    command -v "$1" &>/dev/null
}

tk_fn_exist() {
    [[ -z $1 ]] && tk_print_error "tk_fn_exist(): expects function name as the parameter" && return 1
    [[ $(type -t "$1") == "function" ]]
}

tk_is_login_shell() {
    shopt -q login_shell
}

tk_version_of_path() {
    [[ -z $1 ]] && tk_print_error "tk_version_of_path(): expects path as the parameter" && return 1
    local version
    version=${1##*/}
    version=${version#*-}
    echo "$version"
}

: "${tk_bm_num_times:=1000}"

tk_bm() {
    if [[ $# = 0 ]]; then
        cat << EOF
Usage:

  tk_bm true              Measure baseline latency
  tk_bm whoami            Benchmark a command (here, whoami)
  tk_bm '[[ \$UID = 0 ]]'  Benchmark a shell command

Use the tk_bm_num_times shell variable to control the number of
benchmark iterations (currently $tk_bm_num_times).
EOF
        return 2
    fi

    local num_times=${tk_bm_num_times:-1000}
    local TIMEFORMAT=%3R
    local cmd="$*"

    eval "__tk_bm_cmd() { $cmd; }"

    local total_secs per_cmd_ms
    total_secs=$({ time for (( r=0; r < num_times; r+=1 )); do __tk_bm_cmd >/dev/null; done; true; } 2>&1)
    per_cmd_ms=$(printf "scale=10\n(%s / %s) * 1000\n" "$total_secs" "$num_times" | bc)

    unset __tk_bm_cmd

    printf '%.3f secs for %d times run command: %s\n%.3f ms/command\n' "$total_secs" "$num_times" "$cmd" "$per_cmd_ms"
}