# ~/.bashrc: executed by bash(1) for non-login shells

#-- helpers ------------------------------------------------------------------

error_msg() {
    echo "${1}" >&2
}

cmd_exists() {
    [[ -z "$1" ]] && error_msg "cmd_exists(): expects command name as the parameter" && return 1
    hash "$1" 2>&-
}

fn_exists() {
    [[ -z "$1" ]] && error_msg "fn_exists(): expects function name as the parameter" && return 1
    [[ `type -t "${1}"` == 'function' ]]
}

#-- platform independent environment -----------------------------------------

# localization
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# local system executables take precedence over global system executables
[[ -d /usr/local/bin ]] && export PATH=/usr/local/bin:"${PATH}"
[[ -d /usr/local/sbin ]] && export PATH=/usr/local/sbin:"${PATH}"

# my local executables take precedence over everything else
[[ -d ~/bin ]] && export PATH=~/bin:"${PATH}"

# same as above for local system man pages
[[ -d /usr/local/share/man ]] && export MANPATH=/usr/local/share/man:"${MANPATH}"

# disable core dumps; to enable them: `ulimit -S -c unlimited`
ulimit -S -c 0

# new file permissions: read-write for you, read for group, read for others
umask 0022

# check the window size after each command
shopt -s checkwinsize

# less: ignore character case in searches and display ANSI colors
export LESS="-iR"

# choose default editor
if [[ -n `which emacsclient` ]]; then
    export EDITOR="emacsclient"
else
    export EDITOR="vi"
fi

# C/C++
export CC=/usr/bin/gcc
#export CC="ccache gcc"
#export CXX="ccache g++"
#export CCACHE_DIR=/tmp/${USER}/.ccache
#mkdir -p  /tmp/${USER}/.ccache

# Apache Maven 2
export M2_REPO=~/.m2/repository

# JRebel
export REBEL_HOME=~/opt/jrebel

# npm for node.js
export NODE_PATH=/usr/local/lib/node_modules

# Scala
export SCALA_HOME=/usr/local/Cellar/scala/2.8.1/libexec

# rbenv
cmd_exists 'rbenv' && eval "$(rbenv init -)"

#-- OS X specific environment ------------------------------------------------

if [[ `uname` = Darwin ]]; then
    export JAVA_HOME=`/usr/libexec/java_home | tail -1`

    [[ -r `brew --prefix`/etc/bash_completion ]] && source "`brew --prefix`/etc/bash_completion"

    [[ -r `brew --prefix git`/share/git-core/contrib/completion/git-prompt.sh ]] && source "`brew --prefix git`/share/git-core/contrib/completion/git-prompt.sh"

    # tar does not copy "._*" files
    export COPYFILE_DISABLE=true
fi

#-- user's "hidden" environment ----------------------------------------------

[[ -r ~/.shenv ]] && source ~/.shenv

#-- shell interaction --------------------------------------------------------

# set only if running interactively
if [[ -n $PS1 ]]; then
    # at shell exit, append history to the history file rather than overwrite it
    shopt -s histappend

    # ignore commands that begin with space and duplicate commands
    export HISTCONTROL=ignoreboth
    export HISTFILESIZE=2000
    export HISTSIZE=2000

    # git prompt configuration
    export GIT_PS1_SHOWDIRTYSTATE=true
    export GIT_PS1_SHOWSTASHSTATE=
    export GIT_PS1_SHOWUNTRACKEDFILES=true
    export GIT_PS1_SHOWUPSTREAM="auto"

    # color support for prompt and ls
    if [[ -x /usr/bin/tput ]] && tput setaf 1 &>/dev/null; then
        case "`uname`" in
        Darwin)
            export LSCOLORS="Hxgxfxdxcxegedabagacad"
            alias ls='ls -FG'
            ;;
        Linux)
            [[ -r "${HOME}/.dircolors" ]] && DIR_COLORS="$HOME/.dircolors"
            [[ -r "${DIR_COLORS}" ]] || DIR_COLORS=""
            eval "`dircolors -b ${DIR_COLORS}`"
            alias ls='ls -F --color=auto'
            ;;
        esac
        prompt_user_and_host="\[\033[0;32m\][\u@\h]\[\033[0m\] "
        prompt_pwd="\[\033[1;33m\][\w]\[\033[0m\] "
        prompt_end="\[\033[1;32m\]$\[\033[0m\] "
    else
        prompt_user_and_host="[\u@\h] "
        prompt_pwd="[\w] "
        prompt_end="$ "
    fi
    prompt_git=""
    fn_exists __git_ps1 && prompt_git="\$(__git_ps1 '[git: %s] ')"
    prompt_rbenv=""
    cmd_exists 'rbenv' && prompt_rbenv="[ruby: \$(rbenv version-name)] "
    PS1="${prompt_user_and_host}${prompt_pwd}${prompt_git}${prompt_rbenv}\n${prompt_end}"
    unset prompt_user_and_host prompt_rbenv prompt_pwd prompt_git prompt_end

    # if this is an xterm set the title to user@host:dir
    case "${TERM}" in
    xterm*|rxvt*)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
        ;;
    *)
        ;;
    esac

    if [[ -d ~/lib/bash-completion ]]; then
        for completion_file in ~/lib/bash-completion/*.bash; do
            source "$completion_file"
        done
    fi

    gem_search_paths() {
        local paths=() gem_base_dir=$(gem env gemdir)
        [[ -d "$gem_base_dir" ]] && paths+=("$gem_base_dir")
        [[ ${#paths[@]} -le 0 ]] && error_msg "gem_search_paths(): no gem paths found" && return 1
        echo "${paths[@]}"
    }

    gemdoc() {
        [[ -z "$1" ]] && error_msg "gemdoc(): expects gem and its version as the parameter" && return 1

        local last gems found
        found=0
        for path in $(gem_search_paths); do
            gems=("$path"/doc/$1*/rdoc/index.html)
            last=${gems[@]: -1}
            if [[ -r "$last" ]]; then
                found=1
                break
            fi
        done
        if [[ $found -ne 0 ]]; then
            open "$last"
        else
            echo "not found"
        fi
    }

    _gemdoc() {
        local gemdocs=()
        for path in $(gem_search_paths); do
            gemdocs+=($(\find "$path/doc" -name '*' -type d -depth 1 -exec basename '{}' ';'))
        done
        echo "${gemdocs[@]}"
    }

    complete -W '$(_gemdoc)' gemdoc

    gemedit() {
        [[ -z "$1" ]] && error_msg "gemedit(): expects gem and its version as the parameter" && return 1

        local last gems found
        found=0
        for path in $(gem_search_paths); do
            gems=("$path"/gems/$1*)
            last=${gems[@]: -1}
            if [[ -d "$last" ]]; then
                found=1
                break
            fi
        done
        if [[ $found -ne 0 ]]; then
            $EDITOR "$last"
        else
            echo "not found"
        fi
    }

    _gemedit() {
        local gems=()
        for path in $(gem_search_paths); do
            gems+=($(\find "$path/gems" -name '*' -type d -depth 1 -exec basename '{}' ';'))
        done
        echo "${gems[@]}"
    }

    complete -W '$(_gemedit)' gemedit

    gemdir() {
        pushd "$(gem env gemdir)/gems"
    }

    alias bashrc='$EDITOR ~/.bashrc && source ~/.bashrc'
    alias duff='diff -u'
    alias et='$EDITOR'
    alias ll='ls -la'
    alias todo='$EDITOR ~/TODO.md'

    # greets at login
    cmd_exists 'fortune' && echo && fortune -o
fi