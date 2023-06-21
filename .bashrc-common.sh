#!/usr/bin/env bash

# New file permissions: read-write for you, read for group, read for
# others
umask 0022

# Disable core dumps; to enable them: `ulimit -S -c unlimited`
ulimit -S -c 0

# shellcheck disable=SC2154
if [[ $tk__uname == Darwin* ]]; then
    # Soft limit for the maximum number of open file descriptors
    ulimit -S -n 10240

    # Tar should not copy `._*` files
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
        # variables (`env -i`): if `$JAVA_HOME` is already set, the tool
        # returns the existing value in `$JAVA_HOME` regardless of
        # options
        java_home=$(env -i "$tool_path" "${tool_opts[@]}") || return 1

        local manpath=":$MANPATH:"
        manpath=${manpath//:$JAVA_HOME\/man:/:}
        manpath=${manpath#:}
        manpath=${manpath%:}

        export JAVA_HOME="$java_home"
        export MANPATH="${java_home}/man${manpath:+:$manpath}"
    }

    tk__setup_brew() {
        tk__brew_path=$1
        tk__brew_should_export_path=${2:-}
        tk__brew_manpath=${3:-}

        if tk_is_login_shell; then
            export HOMEBREW_NO_INSECURE_REDIRECT=1
            export HOMEBREW_NO_ANALYTICS=1

            [[ -n $tk__brew_should_export_path ]] && export PATH="${tk__brew_path:+${tk__brew_path}/bin}:$PATH"

            # Set manpath to contain system paths by having the colon
            # character in the end
            export MANPATH="$tk__brew_manpath:"

            # Put selected Homebrew installed tools before system paths.
            # You can find the paths with `brew --prefix $tool`. Use
            # pre-calculated paths, as `brew --prefix` is slow.
            local tools=(
                opt/libpq
            )
            local tool_subpath
            for tool_subpath in "${tools[@]}"; do
                local path="${tk__brew_path}/${tool_subpath}/bin"
                [[ -d $path && -x $path ]] && export PATH="$path:$PATH"
            done
        fi

        # Install chnode
        local chnode_path="${tk__brew_path}/opt/chnode/share/chnode/chnode.sh"
        [[ -r $chnode_path ]] && source "$chnode_path"

        # Install chruby
        local chruby_path="${tk__brew_path}/opt/chruby/share/chruby/chruby.sh"
        [[ -r $chruby_path ]] && source "$chruby_path"
    }

    if [[ $tk__uname == *arm64 && -x /opt/homebrew/bin/brew ]]; then
        tk__setup_brew /opt/homebrew 1 /opt/homebrew/share/man
    elif [[ -x /usr/local/bin/brew ]]; then
        tk__setup_brew /usr/local
    fi

    unset tk__setup_brew
fi

if tk_is_login_shell; then
    # My local executables
    [[ -d ~/bin ]] && export PATH=~/bin:"$PATH"

    # Localization
    export LANG=en_US.UTF-8

    # Bash: ignore commands that begin with space and duplicate commands
    export HISTCONTROL=erasedups:ignoreboth
    export HISTIGNORE='bg?( *):clear:exit:fg?( *):history?( *):ll:ls?( *):reset'
    export HISTTIMEFORMAT='%F %T '
    export HISTFILESIZE=10000
    export HISTSIZE=10000

    # Apache Maven
    [[ -d ~/.m2/repository ]] && export M2_REPO=~/.m2/repository

    # Ripgrep (rg)
    [[ -r ~/.ripgreprc ]] && export RIPGREP_CONFIG_PATH=~/.ripgreprc

    # Less: ignore character case in searches, display ANSI colors, highlight the
    # first unread line, show verbose prompt
    export LESS=-iRWMFX
    export PAGER=less

    # GNU Global
    export GTAGS_OPTIONS="--accept-dotfiles"
    export GTAGSLABEL=default

    # Git: prompt configuration
    export GIT_PS1_SHOWDIRTYSTATE=true
    export GIT_PS1_SHOWSTASHSTATE=
    export GIT_PS1_SHOWUNTRACKEDFILES=true
    export GIT_PS1_SHOWUPSTREAM=auto

    # ShellCheck config
    export SHELLCHECK_OPTS="-e SC1090 -e SC1091"

    # Choose default editor
    export EDITOR
    if tk_cmd_exist emacsclient; then
        EDITOR=$(command -v emacsclient)
    else
        EDITOR=$(command -v vi)
    fi

    # Select Node.js if chnode is installed
    tk_cmd_exist chnode && chnode node-18

    # Select Ruby if chruby is installed
    tk_cmd_exist chruby && chruby ruby-3

    # Python user installs
    export PYTHONUSERBASE=~/.local
    export PATH="$PATH:$PYTHONUSERBASE/bin"

    # Select Java if chjava is installed
    tk_cmd_exist chjava && chjava default
fi
