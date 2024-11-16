#!/usr/bin/env bash

set -euo pipefail

# needed for determining $SOURCE_DIR and expanding pattern bin/*
cd "${0%/*}" || exit 1
SOURCE_DIR=$(pwd -P)

INSTALL_BY_COPYING_DARWIN=(
    # XCode preferences must be copied instead of symlinking, because
    # modifying them in XCode replaces the symlink with a new copy.
    Library/Developer/Xcode/UserData/KeyBindings/tkareine.idekeybindings

    # Must be copied, symlinked file has no effect.
    Library/KeyBindings/DefaultKeyBinding.dict
)

INSTALL_BY_SYMLINKING_COMMON=(
    .Brewfile
    .bash_profile
    .bashrc
    .bashrc-common.sh
    .bashrc-ps1.sh
    .bashrc-support.sh
    .cargo/config.toml
    .ctags.d/custom.ctags
    .dircolors
    .eslintrc.json
    .gemrc
    .gitconfig
    .gitignore
    .globalrc
    .inputrc
    .irbrc
    .lein/profiles.clj
    .prettierrc.js
    .psqlrc
    .ripgreprc
    .rubocop.yml
    .rustfmt.toml
    .tmux.conf
    .vimrc
    bin/ansi-colors.sh
    bin/curl-time
    bin/git-short-rev
    bin/psql-jq
    bin/ssl-tool
    bin/teebug
    bin/tools-update
    bin/yaml2json
)

INSTALL_BY_SYMLINKING_DARWIN=(
    .macos.sh
    'Library/Application Support/Firefox/Profiles/tkareine/user.js'
    'Library/Application Support/Firefox/profiles.ini.example'
    'Library/Application Support/JetBrains/IntelliJIdea2024.2/idea.vmoptions'
    'Library/Application Support/iTerm2/DynamicProfiles/dynamic-profiles.json'
    Library/Thunderbird/Profiles/tkareine/user.js
    Library/Thunderbird/profiles.ini.example
)

print_error() {
    echo "$@" >&2
}

print_usage() {
    cat << EOF
Usage: ${0##*/} [-f] [-h]
Install dotfiles by copying or symlinking to user's home directory.

    -h, --help      display this help and exit
    -f, --force     overwrite existing installed files
EOF
}

install_by_copying() {
    local source destination

    [[ $# -le 0 || -z $1 ]] && print_error "install_by_copying(): expects file paths as parameters" && return 1

    local file
    for file in "$@"; do
        source="$SOURCE_DIR/$file"
        destination=~/"$file"

        if [[ -f $destination ]] && cmp -s "$source" "$destination"; then
            echo "installed already, skipping: $destination"
        elif [[ ! -e $destination || $force_install ]]; then
            echo "copying: $destination -> $source"
            mkdir -p "$(dirname "$destination")"
            cp "$source" "$destination"
        else
            echo "exists already, skipping: $destination"
        fi
    done
}

install_by_symlinking() {
    local source destination

    [[ $# -le 0 || -z $1 ]] && print_error "install_by_symlinking(): expects file paths as parameters" && return 1

    local file
    for file in "$@"; do
        source="$SOURCE_DIR/$file"
        destination=~/"$file"

        if [[ -L $destination && $source -ef $destination ]]; then
            echo "installed already, skipping: $destination"
        elif [[ ! -e $destination || $force_install ]]; then
            echo "symlinking: $destination -> $source"
            mkdir -p "$(dirname "$destination")"
            ln -sf "$source" "$destination"
        else
            echo "exists already, skipping: $destination"
        fi
    done
}

force_install=

while :; do
    case ${1:-} in
        -h|-\?|--help)
            print_usage
            exit
            ;;
        -f|--force)
            force_install=1
            ;;
        *)
            break
    esac

    shift
done

install_by_symlinking "${INSTALL_BY_SYMLINKING_COMMON[@]}"

if [[ $(uname) == "Darwin" ]]; then
    install_by_copying "${INSTALL_BY_COPYING_DARWIN[@]}"
    install_by_symlinking "${INSTALL_BY_SYMLINKING_DARWIN[@]}"
fi
