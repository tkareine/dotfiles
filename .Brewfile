# # rubocop:disable Naming/FileName
# frozen_string_literal: true

# See
#
# * https://github.com/Homebrew/homebrew-bundle
# * `brew bundle --help`

tap "d12frosted/emacs-plus"
tap "tkareine/chnode"

brew "awscli"
brew "azure-cli"
brew "bash"
brew "bash-completion@2"
brew "chruby"
brew "coreutils"
brew "d12frosted/emacs-plus/emacs-plus@29", args: %w[with-modern-icon with-native-comp] if OS.mac?
brew "ffmpeg"
brew "fzf"
brew "gcc"  # Required for emacs-plus (with-native-comp) when Emacs compiles `*.elc` files asynchronously (JIT)
brew "git"
brew "global"
brew "gnupg"
brew "jq"
brew "libressl"
brew "nmap"
brew "node@22"
brew "openssl@3"
brew "pinentry-mac" if OS.mac?
brew "readline"
brew "ripgrep"
brew "ruby-install"
brew "shellcheck"
brew "tkareine/chnode/chnode"
brew "yt-dlp"
brew "zoxide"

cask "alfred"
cask "betterdisplay"
cask "firefox"
cask "gitup"
cask "imageoptim"
cask "iterm2"
cask "jdk-mission-control"
cask "keepassxc"
cask "rectangle"
cask "spotify"
cask "temurin@21"
cask "thunderbird"
