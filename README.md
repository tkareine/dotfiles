# My dotfiles

They're here so that I can synchronize them to computers I work with.

I have copied or adapted some contents from others. For small chunks of
code, I have embedded the source URL in a comment inside the file. When
copying has been extensive, I have retained the original copyright in
the file. Thank you all!

## Installation

Install the dotfiles with `./install.sh`, which either symlinks or
copies each file to your home directory. Installation is safe by
default: if the target file exists in your home directory already, the
installer skips symlinking or copying. See `./install -h` for more.

### Homebrew

On macOS, [install Homebrew][Homebrew install] to a subdirectory under
home:

``` bash
mkdir brew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C brew
export PATH="$PATH:$HOME/brew/bin"
brew update
```

### Bash

Installing the latest version of Bash, using [Homebrew] on macOS:

``` bash
brew install bash
sudo bash -c 'echo ~/brew/bin/bash >> /etc/shells'
chsh -s ~/brew/bin/bash
```

### Xcode Zenburn color theme

I have adapted Bozhidar Batsov's [Emacs Zenburn] color theme for Xcode:

<img src="https://github.com/tkareine/dotfiles/raw/master/images/xcode-tkareine-zenburn-input.png" title="Zenburn color theme for Xcode" alt="Zenburn color theme for Xcode" width="688">

I prefer to use [Input font] (with these
[settings](http://input.fontbureau.com/download/index.html?size=14&language=python&theme=solarized-dark&family=InputMono&width=300&weight=400&line-height=1.1&a=ss&g=ss&i=serifs_round&l=serifs_round&zero=0&asterisk=height&braces=straight&preset=consolas&customize=please))
for Xcode's source editor view, but you can change the font with ease:
in Xcode's Preferences → Fonts & Colors → tkareine-zenburn → Source
Editor, select all the list items with Cmd+A and click on the font icon
at the bottom to select another font for all the items.

For installing the theme manually, copy
`Library/Developer/Xcode/UserData/FontAndColorThemes/tkareine-zenburn.dvtcolortheme`
file to `~/Library/Developer/Xcode/UserData/FontAndColorThemes/`
directory.

[Jari Nurminen](http://kippura.org/zenburnpage/) invented the theme
originally.

[Emacs Zenburn]: https://github.com/bbatsov/zenburn-emacs
[Homebrew]: https://brew.sh/
[Homebrew install]: https://docs.brew.sh/Installation
[Input font]: http://input.fontbureau.com/
