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

# optimization: cache whether we use color prompt or not
if tk_is_color_term; then
    tk__use_color_prompt=1
    tk__ansi_bold_red='\[\e[1;31m\]'
    tk__ansi_bold_yellow='\[\e[1;33m\]'
    tk__ansi_gray_dark='\[\e[90m\]'
    tk__ansi_bold_gray_dark='\[\e[1;90m\]'
    tk__ansi_bold_256_teal_light='\[\e[1;38;5;44m\]'
    tk__ansi_256_orange_light='\[\e[38;5;215m\]'
    tk__ansi_256_teal_dark='\[\e[38;5;30m\]'
    tk__ansi_reset='\[\e[0m\]'
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
            last_cmd_exit_status_color=$tk__ansi_bold_gray_dark
        else
            last_cmd_exit_status_color=$tk__ansi_bold_red
        fi
        last_cmd_exit_status="${last_cmd_exit_status_color}${tk__last_cmd_exit_status}${tk__ansi_reset} "
        user_and_host="${tk__ansi_256_teal_dark}\\u@\\h${tk__ansi_reset} "
        cwd="${tk__ansi_bold_yellow}\\w${tk__ansi_reset} "
        if tk_is_root; then
            end="${tk__ansi_bold_red}#${tk__ansi_reset} "
        else
            end="${tk__ansi_bold_256_teal_light}\$${tk__ansi_reset} "
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
        [[ -n $tk__use_color_prompt ]] && git="${tk__ansi_256_orange_light}${git}${tk__ansi_reset}"
    fi

    local python_venv
    if [[ -n $VIRTUAL_ENV ]]; then
        if (( ${PIPENV_ACTIVE:-0} > 0)); then
            python_venv="(pipenv) "
        else
            python_venv="(venv) "
        fi
    fi

    local host_extras
    tk_fn_exist tk_set_prompt_hook_host_extras && host_extras="$(tk_set_prompt_hook_host_extras)"

    local bin_states=()

    [[ -n $CHNODE_ROOT ]] && bin_states+=("n:$(tk_version_of_path "$CHNODE_ROOT")")

    [[ -n $RUBY_ROOT ]] && bin_states+=("r:$(tk_version_of_path "$RUBY_ROOT")")

    if [[ $tk__uname == "Darwin" ]]; then
        local bin_java
        bin_java=$(tk_current_java_version)
        [[ -n $bin_java ]] && bin_states+=("j:$bin_java")
    fi

    local bin_summary
    if (( ${#bin_states[@]} > 0 )); then
        bin_summary="($(tk_join ' ' "${bin_states[@]}"))"
        [[ -n $tk__use_color_prompt ]] && bin_summary="${tk__ansi_gray_dark}${bin_summary}${tk__ansi_reset}"
    fi

    PS1="${last_cmd_exit_status}${user_and_host}${cwd}${git}${python_venv}${host_extras}${bin_summary}\\n${end}"
}

tk__last_cmd_exit_status=0

tk_prompt_command() {
    tk__last_cmd_exit_status=$?
    history -a
    tk_set_prompt
}

tk_set_title() {
    echo -ne "\\e]0;${USER}@${HOSTNAME}: ${PWD/$HOME/\~}\\007"
}

# install system bash completions
[[ -f /etc/bash_completion && -r /etc/bash_completion ]] && source /etc/bash_completion

# install bash completions for tools from Homebew
[[ $tk__brew_path && -r ${tk__brew_path}/etc/bash_completion ]] && source "${tk__brew_path}/etc/bash_completion"

# install my local bash completions
if [[ -d ~/.bash_completion.d && -x ~/.bash_completion.d ]]; then
    for file in ~/.bash_completion.d/*; do
        if [[ -f $file && -r $file ]]; then
            source "$file"
        fi
    done
    unset file
fi

if [[ $tk__uname == "Darwin" ]] && ! /usr/bin/ssh-add -l >/dev/null; then
    # ssh: load identities with passwords from user's keychain
    /usr/bin/ssh-add -A 2>/dev/null
fi

# bash: check the window size after each command
shopt -s checkwinsize

# bash: at shell exit, append history to the history file rather than
# overwrite it
shopt -s histappend

# bash: attempt to save all lines of a multiple-line command in the same
# history entry
shopt -s cmdhist

# bash: enable extended pattern matching features
shopt -s extglob

if ((BASH_VERSINFO[0] >= 4)); then
    # bash: pattern ** used in a pathname expansion context will match all
    # files and zero or more directories and subdirectories
    shopt -s globstar

    # bash: attempt spelling correction on directory names during word
    # completion if the directory name initially supplied does not exist
    shopt -s dirspell
fi

# bash: ignore commands that begin with space and duplicate commands
export HISTCONTROL=erasedups:ignoreboth
export HISTIGNORE=bg:clear:exit:fg:history:ll:ls:reset
export HISTTIMEFORMAT='%F %T '
export HISTFILESIZE=10000
export HISTSIZE=10000

# color support for ls
if tk_is_color_term; then
    case $tk__uname in
        Darwin)
            export LSCOLORS="Hxgxfxdxcxegedabagacad"
            if tk_cmd_exist gls && tk_cmd_exist gdircolors; then
                if [[ -r ~/.dircolors ]]; then
                    eval "$(gdircolors -b ~/.dircolors)"
                else
                    eval "$(gdircolors -b)"
                fi
                alias ls='gls -F --color=auto'
            else
                alias ls='ls -FG'
            fi
            ;;
        Linux)
            if [[ -r ~/.dircolors ]]; then
                eval "$(dircolors -b ~/.dircolors)"
            else
                eval "$(dircolors -b)"
            fi
            alias ls='ls -F --color=auto'
            ;;
    esac
fi

alias ll='ls -lhA'

# grep: color support
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias hgrep='history | \egrep --color=auto -i'

# less: ignore character case in searches, display ANSI colors, highlight the
# first unread line, show verbose prompt
export LESS=-iRWMFX
export PAGER=less

# git: prompt configuration
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWSTASHSTATE=
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWUPSTREAM=auto

alias g='git'
alias gd='git diff --no-index'

# choose default editor
export EDITOR
if tk_cmd_exist emacsclient; then
    EDITOR=$(command -v emacsclient)
else
    EDITOR=$(command -v vi)
fi

# Ruby: shorten commonly used Bundler command
alias be='bundle exec'

# Python user installs
export PYTHONUSERBASE=~/.local
export PATH="$PATH:$PYTHONUSERBASE/bin"

# ShellCheck config
export SHELLCHECK_OPTS="-e SC1090 -e SC1091"

# list TCP listen and UDP ports
alias linet='lsof -i UDP -i TCP -s TCP:LISTEN -n -P +c 0'

alias wtfdt='date '\''+%Y-%m-%dT%H:%M:%S%z (%Z) (week %W) (epoch %s)'\'''

# install prompt command
PROMPT_COMMAND=tk_prompt_command';'${PROMPT_COMMAND:+$'\n'$(tk_trim "$PROMPT_COMMAND")}
[[ $TERM == xterm* ]] && PROMPT_COMMAND=$PROMPT_COMMAND$'\n'tk_set_title';'

# greets at login
tk_cmd_exist fortune && echo && fortune -a

((BASH_VERSINFO[0] < 4)) && echo -e "\\nWARN: old bash version: $BASH_VERSION"
