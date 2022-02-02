#!/usr/bin/env bash

# new file permissions: read-write for you, read for group, read for others
umask 0022

# disable core dumps; to enable them: `ulimit -S -c unlimited`
ulimit -S -c 0

# shellcheck disable=SC2154
if [[ $tk__uname == "Darwin" ]]; then
    # soft limit for the maximum number of open file descriptors
    ulimit -S -n 10240

    # tar does not copy "._*" files
    tk_is_login_shell && export COPYFILE_DISABLE=true

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
                "$tool_path" -V
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
        # macOS Big Sur: run `java_home` with empty environment
        # variables (`env -i`): if $JAVA_HOME is already set, the tool
        # returns the existing value in $JAVA_HOME regardless of
        # options.
        java_home=$(env -i "$tool_path" "${tool_opts[@]}") || return 1

        local manpath=:$MANPATH:
        manpath=${manpath//:$JAVA_HOME\/man:/:}
        manpath=${manpath#:}
        manpath=${manpath%:}

        export JAVA_HOME=$java_home
        export MANPATH=${java_home}/man${manpath:+:$manpath}
    }

    if [[ -x /usr/local/bin/brew ]]; then
        tk__setup_brew() {
            tk__brew_path=$1

            if tk_is_login_shell; then
                export HOMEBREW_NO_INSECURE_REDIRECT=1
                export HOMEBREW_NO_ANALYTICS=1

                # Put selected brew-installed tools before system paths. You can
                # find the paths with `brew --prefix $tool`. Use pre-calculated
                # paths, as `brew --prefix` is slow.
                local tools=(
                    opt/libpq
                )
                local tool_subpath
                for tool_subpath in "${tools[@]}"; do
                    local path=${tk__brew_path}/${tool_subpath}/bin
                    [[ -d $path && -x $path ]] && export PATH="$path:$PATH"
                done
            fi

            # install chnode
            local chnode_path=${tk__brew_path}/opt/chnode/share/chnode/chnode.sh
            [[ -r $chnode_path ]] && source "$chnode_path"

            # install chruby
            local chruby_path=${tk__brew_path}/opt/chruby/share/chruby/chruby.sh
            [[ -r $chruby_path ]] && source "$chruby_path"
        }

        tk__setup_brew /usr/local
        unset tk__setup_brew
    fi
fi

if tk_is_login_shell; then
    # my local executables
    [[ -d ~/bin ]] && export PATH=~/bin:"$PATH"

    # set manpath to contain system paths
    export MANPATH=:

    # localization
    export LANG=en_US.UTF-8

    # bash: ignore commands that begin with space and duplicate commands
    export HISTCONTROL=erasedups:ignoreboth
    export HISTIGNORE='bg?( *):clear:exit:fg?( *):history?( *):ll:ls?( *):reset'
    export HISTTIMEFORMAT='%F %T '
    export HISTFILESIZE=10000
    export HISTSIZE=10000

    # Apache Maven
    [[ -d ~/.m2/repository ]] && export M2_REPO=~/.m2/repository

    # ripgrep (rg)
    [[ -r ~/.ripgreprc ]] && export RIPGREP_CONFIG_PATH=~/.ripgreprc

    # less: ignore character case in searches, display ANSI colors, highlight the
    # first unread line, show verbose prompt
    export LESS=-iRWMFX
    export PAGER=less

    # GNU Global
    export GTAGS_OPTIONS="--accept-dotfiles"

    # git: prompt configuration
    export GIT_PS1_SHOWDIRTYSTATE=true
    export GIT_PS1_SHOWSTASHSTATE=
    export GIT_PS1_SHOWUNTRACKEDFILES=true
    export GIT_PS1_SHOWUPSTREAM=auto

    # ShellCheck config
    export SHELLCHECK_OPTS="-e SC1090 -e SC1091"

    # choose default editor
    export EDITOR
    if tk_cmd_exist emacsclient; then
        EDITOR=$(command -v emacsclient)
    else
        EDITOR=$(command -v vi)
    fi

    # select Node.js if chnode is installed
    tk_cmd_exist chnode && chnode node-16

    # select Ruby if chruby is installed
    tk_cmd_exist chruby && chruby ruby-3

    # Python user installs
    export PYTHONUSERBASE=~/.local
    export PATH="$PATH:$PYTHONUSERBASE/bin"

    # select Java if chjava is installed
    tk_cmd_exist chjava && chjava default
fi
