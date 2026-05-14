#!/usr/bin/env bash

set -euo pipefail

# Needed for determining $SOURCE_DIR and expanding pattern bin/*
cd "${0%/*}" || exit 1
SOURCE_DIR=$(pwd -P)

INSTALL_DOTFILES_BY_COPYING_DARWIN=(
    # XCode preferences must be copied instead of symlinking, because
    # modifying them in XCode replaces the symlink with a new copy.
    Library/Developer/Xcode/UserData/KeyBindings/tkareine.idekeybindings

    # Must be copied, symlinked file has no effect.
    Library/KeyBindings/DefaultKeyBinding.dict
)

INSTALL_DOTFILES_BY_SYMLINKING_COMMON=(
    .bash_profile
    .bashrc
    .bashrc-common.sh
    .bashrc-ps1.sh
    .bashrc-support.sh
    .cargo/config.toml
    .config/git/config
    .config/git/ignore
    .config/homebrew/Brewfile
    .config/homebrew/brew.env
    .config/k9s/config.yaml
    .config/pgcli/config
    .config/rubocop/config.yml
    .config/tmux/tmux.conf
    .config/vim/vimrc
    .ctags.d/custom.ctags
    .dircolors
    .eslintrc.json
    .gemrc
    .globalrc
    .inputrc
    .irbrc
    .lein/profiles.clj
    .npmrc
    .prettierrc.js
    .psqlrc
    .ripgreprc
    .rustfmt.toml
    bin/ansi-colors.sh
    bin/curl-time
    bin/git-short-rev
    bin/psql-jq
    bin/ssl-tool
    bin/teebug
    bin/tools-update
    bin/yaml2json
)

INSTALL_DOTFILES_BY_SYMLINKING_DARWIN=(
    .macos.sh
    'Library/Application Support/Firefox/Profiles/tkareine/user.js'
    'Library/Application Support/Firefox/profiles.ini.example'
    'Library/Application Support/JetBrains/IntelliJIdea2026.1/idea.vmoptions'
    'Library/Application Support/iTerm2/DynamicProfiles/dynamic-profiles.json'
    Library/Thunderbird/Profiles/tkareine/user.js
    Library/Thunderbird/profiles.ini.example
)

# shellcheck disable=2034
declare -A INSTALL_SYMLINKS_DARWIN=(
    ["$HOME/.nodes/node-26"]=/opt/homebrew/opt/node@26
    ["$HOME/.rubies/ruby-4"]=/opt/homebrew/opt/ruby@4
)

print_error() {
    echo "$@" >&2
}

print_usage() {
    cat <<EOF
Usage: ${0##*/} [-f] [-h]
Install dotfiles by copying or symlinking to user's home directory.

    -h, --help      display this help and exit
    -f, --force     overwrite existing installed files
EOF
}

install_copy() {
    local source=$1 destination=$2

    [[ $# -le 1 || -z $source || -z $destination ]] && print_error "install_copy(): expects source and destination as parameters" && return 1

    if [[ -f $destination ]] && cmp -s "$source" "$destination"; then
        echo "installed already, skipping: $destination"
    elif [[ ! -e $destination || $FORCE_INSTALL ]]; then
        echo "copying: $destination -> $source"
        mkdir -p "$(dirname "$destination")"
        rm -f "$destination" # Delete potential destination file that is a symlink to avoid following it
        cp "$source" "$destination"
    else
        echo "exists already, skipping: $destination"
    fi
}

install_symlink() {
    local source=$1 destination=$2

    [[ $# -le 1 || -z $source || -z $destination ]] && print_error "install_symlink(): expects source and destination as parameters" && return 1

    if [[ -L $destination && $source -ef $destination ]]; then
        echo "installed already, skipping: $destination"
    elif [[ ! -e $destination || $FORCE_INSTALL ]]; then
        echo "symlinking: $destination -> $source"
        mkdir -p "$(dirname "$destination")"
        ln -sf "$source" "$destination"
    else
        echo "exists already, skipping: $destination"
    fi
}

install_dotfiles_by_copying() {
    local source destination

    [[ $# -le 0 ]] && print_error "install_dotfiles_by_copying(): expects file paths as parameters" && return 1

    local file
    for file in "$@"; do
        install_copy "$SOURCE_DIR/$file" ~/"$file"
    done
}

install_dotfiles_by_symlinking() {
    local source destination

    [[ $# -le 0 ]] && print_error "install_dotfiles_by_symlinking(): expects file paths as parameters" && return 1

    local file
    for file in "$@"; do
        install_symlink "$SOURCE_DIR/$file" ~/"$file"
    done
}

install_symlinks() {
    local -n asso_array_ref

    [[ $# -le 0 || -z $1 ]] && print_error "install_symlinks(): expects reference to associated array name, where the array maps destination file paths to source file paths" && return 1

    asso_array_ref=$1

    local destination
    for destination in "${!asso_array_ref[@]}"; do
        install_symlink "${asso_array_ref[$destination]}" "$destination"
    done
}

FORCE_INSTALL=

while :; do
    case ${1:-} in
        -h | -\? | --help)
            print_usage
            exit
            ;;
        -f | --force)
            FORCE_INSTALL=1
            ;;
        *)
            break
            ;;
    esac

    shift
done

install_dotfiles_by_symlinking "${INSTALL_DOTFILES_BY_SYMLINKING_COMMON[@]}"

if [[ $OSTYPE == darwin* ]]; then
    install_dotfiles_by_copying "${INSTALL_DOTFILES_BY_COPYING_DARWIN[@]}"
    install_dotfiles_by_symlinking "${INSTALL_DOTFILES_BY_SYMLINKING_DARWIN[@]}"
    install_symlinks INSTALL_SYMLINKS_DARWIN
fi
