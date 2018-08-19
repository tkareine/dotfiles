if [[ $(uname) == "Darwin" ]]; then
    chjava() {
        if [[ -z $1 ]]; then
            /usr/libexec/java_home -V
            return
        fi

        local home
        home=$(/usr/libexec/java_home --failfast -v "$1")

        if [[ $? -eq 0 ]]; then
            echo "Using JVM in $home"
            export JAVA_HOME=$home
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
    colors=$(tput colors 2>/dev/null)
    [[ $? -eq 0 ]] && [[ $colors -ge 8 ]]
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
else
    tkareine__use_color_prompt=
fi

tkareine_set_prompt() {
    local ansi_b_green="\[\e[1;32m\]"
    local ansi_b_red="\[\e[1;31m\]"
    local ansi_b_yellow="\[\e[1;33m\]"
    local ansi_green="\[\e[0;32m\]"
    local ansi_reset="\[\e[0m\]"

    local user_and_host pwd host_extras end git bin_ruby bin_node bin_java

    if [[ -n $tkareine__use_color_prompt ]]; then
        user_and_host="${ansi_green}[\u@\h]${ansi_reset} "
        pwd="${ansi_b_yellow}[\w]${ansi_reset} "
        if tkareine_is_root; then
            end="${ansi_b_red}#${ansi_reset} "
        else
            end="${ansi_b_green}\$${ansi_reset} "
        fi
    else
        user_and_host="[\u@\h] "
        pwd="[\w] "
        if tkareine_is_root; then
            end="# "
        else
            end="$ "
        fi
    fi

    tkareine_fn_exist __git_ps1 && git="$(__git_ps1 '[%s] ')"

    tkareine_fn_exist tkareine_prompt_hook_host_extras && host_extras="$(tkareine_prompt_hook_host_extras)"

    tkareine_cmd_exist chruby && bin_ruby="[$(chruby | grep '\* ' | cut -d ' ' -f 3)] "

    tkareine_cmd_exist nodenv && bin_node="[node-$(nodenv version | cut -d ' ' -f 1)] "

    if [[ $(uname) == "Darwin" ]]; then
        bin_java=$(tkareine_current_java_version)
        [[ -n $bin_java ]] && bin_java="[java-$bin_java] "
    fi

    PS1="${user_and_host}${pwd}${git}${host_extras}${bin_ruby}${bin_node}${bin_java}\n${end}"
}

tkareine_set_title() {
    echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"
}

if [[ $(uname) == "Darwin" ]]; then
    tkareine__setup_brew() {
        export HOMEBREW_NO_INSECURE_REDIRECT=1

        export PATH="$PATH:$HOME/brew/bin"

        # optimization: cache Homebrew installation directory
        local brew_path=$(brew --prefix)

        [[ -r $brew_path/etc/bash_completion ]] && source "$brew_path/etc/bash_completion"

        # LibreSSL (used by Emacs)
        local libressl_path=$(brew --prefix libressl)
        if [[ -d $libressl_path/bin ]]; then
            export PATH="$libressl_path/bin:$PATH"
            [[ -d $libressl_path/share/man ]] && export MANPATH="$libressl_path/share/man:$MANPATH"
        fi

        # chruby
        local chruby_path=$(brew --prefix chruby)/share/chruby/chruby.sh
        if [[ -f $chruby_path ]]; then
            source "$chruby_path"
            chruby ruby-2
        fi
    }

    [[ -x ~/brew/bin/brew ]] && tkareine__setup_brew

    unset tkareine__setup_homebrew

    # ssh: load identities with passwords from user's keychain
    /usr/bin/ssh-add -A 2> /dev/null

    export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null | tail -1)

    source ~/.iterm2_shell_integration.bash
fi

# my local bash completions
if [[ -d ~/lib/bash_completion.d && -x ~/lib/bash_completion.d ]]; then
    for file in ~/lib/bash_completion.d/*; do
        if [[ -f $file && -r $file ]]; then
            source "$file"
        fi
    done
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

if ((${BASH_VERSINFO[0]} >= 4)); then
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
    case $(uname) in
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
export LESS=-iRWM
export PAGER=less

# git: prompt configuration
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWSTASHSTATE=
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWUPSTREAM=auto

# choose default editor
if tkareine_cmd_exist emacsclient; then
    export EDITOR=$(which emacsclient)
else
    export EDITOR=$(which vi)
fi

# Apache Maven
[[ -d ~/.m2/repository ]] && export M2_REPO=~/.m2/repository

# nodenv
tkareine_cmd_exist nodenv && eval "$(nodenv init -)"

# Python user installs
export PYTHONUSERBASE=~/.python2
export PATH="$PATH:$PYTHONUSERBASE/bin"

# greets at login
tkareine_cmd_exist fortune && echo && fortune -a

((${BASH_VERSINFO[0]} < 4)) && echo -e "\nWARN: old bash version: $BASH_VERSION"
