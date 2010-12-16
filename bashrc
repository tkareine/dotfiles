# ~/.bashrc: executed by bash(1) for non-login shells

#-- helpers ------------------------------------------------------------------

fn_exists() {
    if [[ -z "$1" ]]; then
        echo "fn_exists expects function name as the parameter"
    else
        `type ${1} 2> /dev/null | grep -q 'function'`
    fi
}

#-- platform independent environment -----------------------------------------

# localization
export LANG="en_US.UTF-8"

# local system executables take precedence global system executables
[[ -d /usr/local/bin ]] && export PATH=/usr/local/bin:"${PATH}"
[[ -d /usr/local/share/man ]] && export MANPATH=/usr/local/share/man:"${MANPATH}"

# my local executables take precedence over everything else
[[ -d ~/bin ]] && export PATH=~/bin:"${PATH}"

# disable core dumps; to enable them: `ulimit -S -c unlimited`
ulimit -S -c 0

# new file permissions: read-write for you, read for group, read for others
umask 0022

# check the window size after each command
shopt -s checkwinsize

# less: ignore character case in searches and display ANSI colors
export LESS="-iR"

# choose default editor
if [[ -n `which matew` ]]; then
    export EDITOR="matew"
else
    export EDITOR="vi"
fi

# C/C++
#export CC="ccache gcc"
#export CXX="ccache g++"
#export CCACHE_DIR=/tmp/${USER}/.ccache
#mkdir -p  /tmp/${USER}/.ccache

# Apache Maven 2
export M2_REPO=~/.m2/repository

# JRebel
export REBEL_HOME=~/opt/jrebel

# Scala
export SCALA_HOME=/usr/local/Cellar/scala/2.8.1/libexec

# Ruby Version Manager
[[ -s "${HOME}/.rvm/scripts/rvm" ]] && source "${HOME}/.rvm/scripts/rvm"
[[ -r $rvm_path/scripts/completion ]] && source $rvm_path/scripts/completion

#-- OS X specific environment ------------------------------------------------

if [[ `uname` = Darwin ]]; then
    export JAVA_HOME=`/usr/libexec/java_home | tail -1`

    [[ -r `brew --prefix`/etc/bash_completion ]] && source `brew --prefix`/etc/bash_completion

    # tar does not copy "._*" files
    export COPYFILE_DISABLE=true
fi

#-- user's "hidden" environment ----------------------------------------------

[[ -r ~/.shenv ]] && source ~/.shenv

#-- shell interaction ---------------------------------------------------------

# set only if running interactively
if [[ -n $PS1 ]]; then
    # at shell exit, append history to the history file rather than overwrite it
    shopt -s histappend

    # ignore commands that begin with space and duplicate commands
    export HISTCONTROL=ignoreboth
    export HISTFILESIZE=2000
    export HISTSIZE=2000

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
        prompt_user_and_host="\[\033[1;32m\]\u@\h\[\033[0m\] "
        prompt_pwd="\[\033[1;33m\]\w\[\033[0m\] "
        prompt_end="\[\033[1;32m\]$\[\033[0m\] "
    else
        prompt_user_and_host="\u@\h "
        prompt_pwd="\w "
        prompt_end="$ "
    fi
    prompt_git=""
    fn_exists __git_ps1 && prompt_git="\$(__git_ps1 '(%s) ')"
    prompt_rvm=""
    [[ -x ~/.rvm/bin/rvm-prompt ]] && prompt_rvm="\$(~/.rvm/bin/rvm-prompt) "
    PS1="${prompt_user_and_host}${prompt_rvm}${prompt_pwd}${prompt_git}${prompt_end}"
    unset prompt_user_and_host prompt_rvm prompt_pwd prompt_git prompt_end

    # if this is an xterm set the title to user@host:dir
    case "${TERM}" in
    xterm*|rxvt*)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
        ;;
    *)
        ;;
    esac

    if [[ -d ~/lib/bash-completions ]]; then
        for completion_file in ~/lib/bash-completions/*.bash; do
            source "$completion_file"
        done
    fi

    gem_search_paths() {
        local paths=() gem_base_dir=$(gem env gemdir)
        [[ -d "$gem_base_dir" ]]        && paths+=("$gem_base_dir")
        [[ -d "$gem_base_dir@global" ]] && paths+=("$gem_base_dir@global")
        echo "${paths[@]}"
    }

    gemdoc() {
        if [[ -z "$1" ]]; then
            echo "gemdoc expects gem and its version as the parameter"
        else
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
        fi
    }

    _gemdoc() {
        local gemdocs=()
        for path in $(gem_search_paths); do
            gemdocs+=($(\ls "$path"/doc))
        done
        echo "${gemdocs[@]}"
    }

    complete -W '$(_gemdoc)' gemdoc

    gemedit() {
        if [[ -z "$1" ]]; then
            echo "gemedit expects gem and its version as the parameter"
        else
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
        fi
    }

    _gemedit() {
        local gems=()
        for path in $(gem_search_paths); do
            gems+=($(\ls "$path"/gems))
        done
        echo "${gems[@]}"
    }

    complete -W '$(_gemedit)' gemedit

    gemdir() {
        [[ -n "$1" ]] && rvm "$1"
        pushd `rvm gemdir`/gems
    }

    alias bashrc='$EDITOR ~/.bashrc && source ~/.bashrc'
    alias duff='diff -u'
    alias ll='ls -la'
    alias todo='$EDITOR ~/TODO.md'
fi
