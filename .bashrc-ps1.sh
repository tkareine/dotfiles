#!/usr/bin/env bash

tk_is_color_term() {
    local colors
    if colors=$(tput colors 2>/dev/null); then
        ((colors >= 8))
    else
        return 1
    fi
}

tk_is_root() {
    [[ $UID == "0" ]]
}

# Optimization: cache whether we use color prompt or not
if tk_is_color_term; then
    # Syntax:
    #
    # CSI (Control Sequence Introducer) sequences start with `ESC [`.
    # Common sequences are written as `\e[$n1;...;$nN$c]`, where
    # `$n1`…`$nN` are numbers (semicolon-separated, missing number is
    # treated as 0) and `$c` is a letter to select a particular action.
    #
    # SGR (Select Graphic Rendition) parameters are control sequences of
    # `CSI n m`, written as `\e[$n1;...;${nN}m]`
    #
    # See:
    # https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_(Control_Sequence_Introducer)_sequences
    tk__use_color_prompt=1
    tk__ansi_reset='\[\e[0m\]'
    tk__ansi16b_gray_dark='\[\e[90m\]'
    tk__ansi16b_gray_dark_bold='\[\e[1;90m\]'
    tk__ansi256_bluegreen_bold='\[\e[1;38;5;80m\]'
    tk__ansi256_greenblue='\[\e[38;5;72m\]'
    tk__ansi256_red_bold='\[\e[1;38;5;203m\]'
    tk__ansi256_violet_bold='\[\e[1;38;5;176m\]'
else
    tk__use_color_prompt=
fi

# Keep the implementation of this function fast.
#
# To quickly benchmark time taken to display prompt, run `time eval
# "$PROMPT_COMMAND"`.
tk_set_prompt() {
    local last_cmd_exit_status last_cmd_exit_status_color user_and_host cwd end

    if [[ -n $tk__use_color_prompt ]]; then
        if [[ $tk__last_cmd_exit_status == 0 ]]; then
            last_cmd_exit_status_color=$tk__ansi16b_gray_dark_bold
        else
            last_cmd_exit_status_color=$tk__ansi256_red_bold
        fi
        last_cmd_exit_status="${last_cmd_exit_status_color}${tk__last_cmd_exit_status}${tk__ansi_reset} "
        user_and_host="${tk__ansi256_greenblue}\\u@\\h${tk__ansi_reset} "
        cwd="${tk__ansi256_bluegreen_bold}\\w${tk__ansi_reset} "
        if tk_is_root; then
            end="${tk__ansi256_red_bold}#${tk__ansi_reset} "
        else
            end="${tk__ansi256_violet_bold}\$${tk__ansi_reset} "
        fi
    else
        last_cmd_exit_status="${tk__last_cmd_exit_status} "
        user_and_host='\u@\h '
        cwd='\w '
        if tk_is_root; then
            end="# "
        else
            end="$ "
        fi
    fi

    local git
    if tk_fn_exist __git_ps1; then
        git="$(__git_ps1 '%s ')"
        [[ -n $tk__use_color_prompt ]] && git="${tk__ansi256_greenblue}${git}${tk__ansi_reset}"
    fi

    local python_venv
    if [[ -n ${VIRTUAL_ENV:-} ]]; then
        python_venv="(venv) "
    fi

    local host_extras
    tk_fn_exist tk_set_prompt_hook_host_extras && host_extras="$(tk_set_prompt_hook_host_extras)"

    local bin_states=()

    [[ -n $CHNODE_ROOT ]] && bin_states+=("n:$(tk_version_in_path "$CHNODE_ROOT")")

    [[ -n $RUBY_ROOT ]] && bin_states+=("r:$(tk_version_in_path "$RUBY_ROOT")")

    [[ -n $JAVA_HOME ]] && bin_states+=("j:$(tk_version_in_path "$JAVA_HOME")")

    local bin_summary
    if ((${#bin_states[@]} > 0)); then
        bin_summary="($(tk_join ' ' "${bin_states[@]}"))"
        [[ -n $tk__use_color_prompt ]] && bin_summary="${tk__ansi16b_gray_dark}${bin_summary}${tk__ansi_reset}"
    fi

    PS1="${last_cmd_exit_status}${user_and_host}${cwd}${git}${python_venv}${host_extras}${bin_summary}\\n${end}"
}

tk__last_cmd_exit_status=0

tk_prompt_command() {
    tk__last_cmd_exit_status=$?
    history -a
    history -c
    history -r
    tk_set_prompt
}

tk_set_title() {
    echo -ne "\\e]0;${USER}@${HOSTNAME}: ${PWD/$HOME/\~}\\007"
}

# Install system Bash completions
#
# shellcheck disable=SC1091
[[ -f /etc/bash_completion && -r /etc/bash_completion ]] && source /etc/bash_completion

# Install Bash completions for tools from Homebrew (`brew install
# bash-completion@2`); see https://github.com/scop/bash-completion
#
# shellcheck disable=SC1091
[[ $tk__brew_path && -r ${tk__brew_path}/etc/profile.d/bash_completion.sh ]] && source "${tk__brew_path}/etc/profile.d/bash_completion.sh"

# shellcheck disable=SC2154
if [[ $tk__uname == Darwin* ]] && ! /usr/bin/ssh-add -l >/dev/null; then
    # ssh: load identities with passwords from user's keychain
    /usr/bin/ssh-add --apple-load-keychain 2>/dev/null
fi

# Disable XON (^Q) and XOFF (^S) control characters for flow control
stty -ixon

# Bash: check the window size after each command
shopt -s checkwinsize

# Bash: at shell exit, append history to the history file rather than
# overwrite it
shopt -s histappend

# Bash: attempt to save all lines of a multiple-line command in the same
# history entry
shopt -s cmdhist

# Bash: enable extended pattern matching features
shopt -s extglob

if ((BASH_VERSINFO[0] >= 4)); then
    # Bash: pattern `**` used in a pathname expansion context will match
    # all files and zero or more directories and subdirectories
    shopt -s globstar

    # Bash: attempt spelling correction on directory names during word
    # completion if the directory name initially supplied does not exist
    shopt -s dirspell
fi

# Color support for ls
if tk_is_color_term; then
    case $tk__uname in
        Darwin*)
            tk_is_login_shell && export LSCOLORS=Hxgxfxdxcxegedabagacad

            # Install GNU coreutils for from Homebrew (`brew install
            # coreutils`); see https://www.gnu.org/software/coreutils
            if tk_cmd_exist gls && tk_cmd_exist gdircolors; then
                if [[ -r ~/.dircolors ]]; then
                    source <(gdircolors -b ~/.dircolors)
                else
                    source <(gdircolors -b)
                fi
                alias ls='gls -F --color=auto'
            else
                alias ls='ls -FG'
            fi
            ;;
        Linux*)
            if [[ -r ~/.dircolors ]]; then
                source <(dircolors -b ~/.dircolors)
            else
                source <(dircolors -b)
            fi
            alias ls='ls -F --color=auto'
            ;;
    esac
fi

alias ll='ls -lhA'

tk_cmd_exist zoxide && source <(zoxide init --hook pwd bash)

if tk_cmd_exist fzf; then
    tk_is_login_shell && export FZF_DEFAULT_OPTS='--color=pointer:80,prompt:176,info:72'
    FZF_ALT_C_COMMAND='' source <(fzf --bash)
fi

# Grep: color support
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias hgrep='history | \egrep --color=auto -i'

# Git shortcuts
alias g='git'
alias gd='git diff --no-index'

# Ruby: shorten commonly used Bundler command
alias be='bundle exec'

# List TCP listen and UDP ports
alias linet='lsof -i UDP -i TCP -s TCP:LISTEN -n -P +c 0'

alias wtfdt='date '\''+%Y-%m-%dT%H:%M:%S%z (%Z W%W epoch=%s)'\'''

alias tmuxm='tmux -CC new-session -A -s main'

# Install prompt command
PROMPT_COMMAND=tk_prompt_command';'${PROMPT_COMMAND:+$'\n'$(tk_trim "$PROMPT_COMMAND")}
[[ $TERM == xterm* ]] && PROMPT_COMMAND=$PROMPT_COMMAND$'\n'tk_set_title';'

((BASH_VERSINFO[0] < 4)) && echo -e "\\nWARN: old Bash version: $BASH_VERSION"
