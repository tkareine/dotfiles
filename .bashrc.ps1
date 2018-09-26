# optimization: cache current uname
tkareine__uname=$(uname)

if [[ $tkareine__uname == "Darwin" ]]; then
    chjava() {
        local tool_path=/usr/libexec/java_home
        local tool_opts=()

        case ${1:-} in
            -h|-\?|--help)
                cat << EOF
Usage: chjava [JAVA_VERSION|default]
EOF
                return
                ;;
            '')
                $tool_path -V
                return
                ;;
            default)
                tool_opts+=(--failfast)
                ;;
            *)
                tool_opts+=(--failfast)
                tool_opts+=(-v)
                tool_opts+=("$1")
                ;;
        esac

        local java_home
        java_home=$(/usr/libexec/java_home "${tool_opts[@]}") || return 1

        local manpath=:$MANPATH:
        manpath=${manpath//:${JAVA_HOME}\/man:/:}
        manpath=${manpath#:}
        manpath=${manpath%:}

        export JAVA_HOME=$java_home

        if [[ $manpath == :* ]]; then
            export MANPATH=${java_home}/man${manpath}
        else
            export MANPATH=${java_home}/man${manpath:+:$manpath}
        fi
    }

    tkareine_current_java_version() {
        [[ -z $JAVA_HOME ]] && return 1

        local version
        version=${JAVA_HOME#*/jdk}
        version=${version#-}
        version=${version%.jdk*}

        echo "$version"
    }
fi

tkareine_is_color_term() {
    local colors
    if colors=$(tput colors 2>/dev/null); then
        [[ $colors -ge 8 ]]
    else
        return 1
    fi
}

tkareine_is_root() {
    [[ $(whoami) == "root" ]]
}

tkareine_append_history() {
    history -a
}

# optimization: cache whether we use color prompt or not
if tkareine_is_color_term; then
    tkareine__use_color_prompt=1
    tkareine__ansi_b_green='\[\e[1;32m\]'
    tkareine__ansi_b_red='\[\e[1;31m\]'
    tkareine__ansi_b_yellow='\[\e[1;33m\]'
    tkareine__ansi_green='\[\e[0;32m\]'
    tkareine__ansi_reset='\[\e[0m\]'
else
    tkareine__use_color_prompt=
fi

# Keep the implementation of this function fast.
#
# To quickly benchmark time taken to display prompt, run `times` twice
# and compare accumulated user times.
tkareine_set_prompt() {
    local user_and_host cwd end

    if [[ -n $tkareine__use_color_prompt ]]; then
        user_and_host="${tkareine__ansi_green}[\\u@\\h]${tkareine__ansi_reset} "
        cwd="${tkareine__ansi_b_yellow}[\\w]${tkareine__ansi_reset} "
        if tkareine_is_root; then
            end="${tkareine__ansi_b_red}#${tkareine__ansi_reset} "
        else
            end="${tkareine__ansi_b_green}\$${tkareine__ansi_reset} "
        fi
    else
        user_and_host='[\u@\h] '
        cwd='[\w] '
        if tkareine_is_root; then
            end="# "
        else
            end="$ "
        fi
    fi

    local git
    tkareine_fn_exist __git_ps1 && git="$(__git_ps1 '[%s] ')"

    local python_venv
    if [[ -n $VIRTUAL_ENV ]]; then
        if (( ${PIPENV_ACTIVE:-0} > 0)); then
            python_venv="(pipenv) "
        else
            python_venv="(venv) "
        fi
    fi

    local host_extras
    tkareine_fn_exist tkareine_prompt_hook_host_extras && host_extras="$(tkareine_prompt_hook_host_extras)"

    local bin_states=()

    [[ -n $RUBY_ROOT ]] && bin_states+=("$(echo "${RUBY_ROOT##*/}" | tr - :)")

    [[ -n $CHNODE_ROOT ]] && bin_states+=("$(echo "${CHNODE_ROOT##*/}" | tr - :)")

    if [[ $tkareine__uname == "Darwin" ]]; then
        local bin_java
        bin_java=$(tkareine_current_java_version)
        [[ -n $bin_java ]] && bin_states+=("java:$bin_java")
    fi

    local bin_summary
    (( ${#bin_states[@]} > 0 )) && bin_summary="($(tkareine_join ' ' "${bin_states[@]}"))"

    PS1="${user_and_host}${cwd}${git}${python_venv}${host_extras}${bin_summary}\\n${end}"
}

tkareine_set_title() {
    echo -ne "\\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\\007"
}

# my local executables
[[ -d ~/bin ]] && export PATH=~/bin:"$PATH"

# set manpath to contain system paths
export MANPATH=:

if [[ $tkareine__uname == "Darwin" ]]; then
    tkareine__setup_brew() {
        local brew_path=$1

        export HOMEBREW_NO_INSECURE_REDIRECT=1

        # for security, put all brew-installed tools after system paths
        export PATH="$PATH:$brew_path/bin"

        # Put selected brew-installed tools before system paths. You can
        # find the paths with `brew --prefix $tool`. Use pre-calculated
        # paths, as `brew --prefix` is slow.
        local tool_subpath
        for tool_subpath in \
                opt/bash \
                opt/ctags \
                opt/git \
                opt/libressl \
                ; do
            local path=${brew_path}/${tool_subpath}/bin
            [[ -d $path && -x $path ]] && export PATH="$path:$PATH"
        done

        # install bash completions for tools
        local bash_completion_path=${brew_path}/etc/bash_completion
        [[ -r $bash_completion_path ]] && source "$bash_completion_path"

        # install chruby
        local chruby_path=${brew_path}/opt/chruby/share/chruby/chruby.sh
        [[ -r $chruby_path ]] && source "$chruby_path"
    }

    [[ -x ~/brew/bin/brew ]] && tkareine__setup_brew ~/brew

    unset tkareine__setup_homebrew

    # ssh: load identities with passwords from user's keychain
    /usr/bin/ssh-add -A 2>/dev/null
fi

# my local bash completions
if [[ -d ~/.bash_completion.d && -x ~/.bash_completion.d ]]; then
    for file in ~/.bash_completion.d/*; do
        if [[ -f $file && -r $file ]]; then
            source "$file"
        fi
    done
    unset file
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
if tkareine_is_color_term; then
    case $tkareine__uname in
        Darwin)
            export LSCOLORS="Hxgxfxdxcxegedabagacad"
            alias ls='ls -FG'
            ;;
        Linux)
            if [[ -r ~/.dircolors ]]; then
                DIR_COLORS=~/.dircolors
            else
                DIR_COLORS=""
            fi
            eval "$(dircolors -b $DIR_COLORS)"
            alias ls='ls -F --color=auto'
            ;;
    esac
fi

if [[ -n ${precmd_functions+x} ]]; then
    precmd_functions+=(tkareine_append_history tkareine_set_prompt)
    [[ $TERM == xterm* ]] && precmd_functions+=(tkareine_set_title)
else
    PROMPT_COMMAND="tkareine_append_history; tkareine_set_prompt"
    [[ $TERM == xterm* ]] && PROMPT_COMMAND="$PROMPT_COMMAND; tkareine_set_title"
fi

# less: ignore character case in searches, display ANSI colors, highlight the
# first unread line, show verbose prompt
export LESS=-iRWMFX
export PAGER=less

# git: prompt configuration
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWSTASHSTATE=
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWUPSTREAM=auto

# choose default editor
export EDITOR
if tkareine_cmd_exist emacsclient; then
    EDITOR=$(command -v emacsclient)
else
    EDITOR=$(command -v vi)
fi

# Apache Maven
[[ -d ~/.m2/repository ]] && export M2_REPO=~/.m2/repository

# select Ruby if chruby is installed
tkareine_cmd_exist chruby && chruby ruby-2

# install chnode, select Node.js
chnode_path=~/Projects/chnode/chnode.sh
if [[ -f $chnode_path ]]; then
    source "$chnode_path"
    chnode node-10
fi
unset chnode_path

# select Java if chjava is installed
tkareine_cmd_exist chjava && chjava default

# Python user installs
export PYTHONUSERBASE=~/.local
export PATH="$PATH:$PYTHONUSERBASE/bin"

# ShellCheck config
export SHELLCHECK_OPTS="-e SC1090 -e SC1091"

# greets at login
tkareine_cmd_exist fortune && echo && fortune -a

((BASH_VERSINFO[0] < 4)) && echo -e "\\nWARN: old bash version: $BASH_VERSION"
