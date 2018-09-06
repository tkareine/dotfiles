# optimization: cache current uname
tkareine__uname=$(uname)

if [[ $tkareine__uname == "Darwin" ]]; then
    chjava() {
        local tool_path=/usr/libexec/java_home
        local tool_opts=()

        case ${1:-} in
            -h|-\?|--help)
                cat << EOF
Usage: chjava [options] [version]

Set \$JAVA_HOME and \$MANPATH for selected JVM.

    -h  display this help and exit
    -l  list JVMs available

If given no version, output current \$JAVA_HOME.
EOF
                return
                ;;
            '')
                echo "$JAVA_HOME"
                return
                ;;
            -l|--list)
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

        local home
        home=$(/usr/libexec/java_home "${tool_opts[@]}") || return 1

        local manpath
        # bash parameter expansion substitution is slow, use sed instead
        # shellcheck disable=SC2001
        if ! manpath=$(echo "${MANPATH:-:}" | sed "s|${home}[^:]*:||g"); then
            tkareine_print_error "failed to set \$MANPATH, was: $MANPATH"
            return 1
        fi

        export JAVA_HOME=$home
        export MANPATH=${home}/man:${manpath#:}

        echo "$JAVA_HOME"
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
    local user_and_host pwd host_extras end git bin_ruby bin_node bin_java

    if [[ -n $tkareine__use_color_prompt ]]; then
        user_and_host="${tkareine__ansi_green}[\\u@\\h]${tkareine__ansi_reset} "
        pwd="${tkareine__ansi_b_yellow}[\\w]${tkareine__ansi_reset} "
        if tkareine_is_root; then
            end="${tkareine__ansi_b_red}#${tkareine__ansi_reset} "
        else
            end="${tkareine__ansi_b_green}\$${tkareine__ansi_reset} "
        fi
    else
        user_and_host='[\u@\h] '
        pwd='[\w] '
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

    if [[ $tkareine__uname == "Darwin" ]]; then
        bin_java=$(tkareine_current_java_version)
        [[ -n $bin_java ]] && bin_java="[java-$bin_java] "
    fi

    PS1="${user_and_host}${pwd}${git}${host_extras}${bin_ruby}${bin_node}${bin_java}\\n${end}"
}

tkareine_set_title() {
    echo -ne "\\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\\007"
}

# my local executables
[[ -d ~/bin ]] && export PATH=~/bin:"$PATH"

if [[ $tkareine__uname == "Darwin" ]]; then
    tkareine__setup_brew() {
        local brew_path=$1

        export HOMEBREW_NO_INSECURE_REDIRECT=1

        # for security, put all brew-installed tools after system paths
        export PATH="$PATH:$brew_path/bin"

        # Put selected brew-installed tools before system paths. You can
        # find the paths with `brew --prefix $tool`. Use pre-calculated
        # paths, as `brew --prefix` is slow.
        for tool_subpath in \
                /opt/bash \
                /opt/ctags \
                /opt/git \
                /opt/libressl \
                ; do
            local path=${brew_path}/${tool_subpath}/bin
            [[ -d $path && -x $path ]] && export PATH="$path:$PATH"
        done

        # install bash completions for tools
        [[ -r $brew_path/etc/bash_completion ]] && source "$brew_path/etc/bash_completion"

        # install chruby
        local chruby_path=${brew_path}/opt/chruby/share/chruby/chruby.sh
        if [[ -f $chruby_path ]]; then
            source "$chruby_path"
            chruby ruby-2
        fi
    }

    [[ -x ~/brew/bin/brew ]] && tkareine__setup_brew ~/brew

    unset tkareine__setup_homebrew

    # ssh: load identities with passwords from user's keychain
    /usr/bin/ssh-add -A 2>/dev/null

    chjava default > /dev/null

    source ~/.iterm2_shell_integration.bash
fi

# my local bash completions
if [[ -d ~/.bash_completion.d && -x ~/.bash_completion.d ]]; then
    for file in ~/.bash_completion.d/*; do
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

# nodenv
tkareine_cmd_exist nodenv && eval "$(nodenv init -)"

# Python user installs
export PYTHONUSERBASE=~/.local
export PATH="$PATH:$PYTHONUSERBASE/bin"

# ShellCheck config
export SHELLCHECK_OPTS="-e SC1090"

# greets at login
tkareine_cmd_exist fortune && echo && fortune -a

((BASH_VERSINFO[0] < 4)) && echo -e "\\nWARN: old bash version: $BASH_VERSION"
