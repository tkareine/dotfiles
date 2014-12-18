#!/usr/bin/env bash

set -e

# needed for determining $SOURCE_DIR and expanding pattern bin/*
cd "${BASH_SOURCE%/*}" || exit 1
SOURCE_DIR=$(pwd -P)

INSTALL_BY_COPYING_DARWIN=(
    Library/KeyBindings/DefaultKeyBinding.dict
)

INSTALL_BY_SYMLINKING_ALL=(
    .ackrc
    .bash_profile
    .bashrc
    .bashrc.aliases
    .bashrc.common
    .bashrc.functions
    .bashrc.looks
    .dircolors
    .gemrc
    .gitconfig
    .gitignore
    .inputrc
    .irbrc
    .sbtconfig
    .tmux.conf
    .vimrc
    .xmodmap
)

INSTALL_BY_SYMLINKING_ALL+=(bin/*)

INSTALL_BY_SYMLINKING_DARWIN=(
    .bashrc.darwin
    .osx
)

error_msg() {
    echo "$@" >&2
}

install_by_copying() {
    [[ $# -le 0 || -z $1 ]] && error_msg "install_by_copying(): expects file paths as parameters" && return 1
    for file in "$@"; do
        source="$SOURCE_DIR/$file"
        destination=~/"$file"

        if [[ ! -e $destination ]]; then
            echo "copying: $destination -> $source"
            mkdir -p "$(dirname "$destination")"
            cp "$source" "$destination"
        elif [[ -f $destination ]] && cmp -s $source $destination; then
            echo "installed already, skipping: $destination"
        else
            echo "exists already, skipping: $destination"
        fi
    done
}

install_by_symlinking() {
    [[ $# -le 0 || -z $1 ]] && error_msg "install_by_symlinking(): expects file paths as parameters" && return 1
    for file in "$@"; do
        source="$SOURCE_DIR/$file"
        destination=~/"$file"

        if [[ ! -e $destination ]]; then
            echo "linking: $destination -> $source"
            mkdir -p "$(dirname "$destination")"
            ln -sf "$source" "$destination"
        elif [[ -L $destination && $source -ef $destination ]]; then
            echo "installed already, skipping: $destination"
        else
            echo "exists already, skipping: $destination"
        fi
    done
}

install_by_symlinking "${INSTALL_BY_SYMLINKING_ALL[@]}"

if [[ `uname` == Darwin ]]; then
    install_by_copying "${INSTALL_BY_COPYING_DARWIN[@]}"
    install_by_symlinking "${INSTALL_BY_SYMLINKING_DARWIN[@]}"
fi
