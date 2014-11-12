#!/usr/bin/env bash

set -e

cd "$(dirname $0)"

DOTFILES=(
  .ackrc
  .autotest
  .bash_profile
  .bashrc
  .bashrc.aliases
  .bashrc.common
  .bashrc.darwin
  .bashrc.functions
  .bashrc.looks
  .dircolors
  .gemrc
  .gitconfig
  .gitignore
  .inputrc
  .irbrc
  .osx
  .sbtconfig
  .tmux.conf
  .vimrc
  .xmodmap
)
DOTFILES+=(bin/*)

source_dir=$(pwd -P)

for file in "${DOTFILES[@]}"; do
    source="$source_dir/$file"
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
