# My dotfiles

[![CI](https://github.com/tkareine/dotfiles/workflows/CI/badge.svg)][dotfiles-CI]

My public configuration for selected command line tools, in order to
synchronize them to computers I work with.

The dotfiles focus on [GNU Bash] with the goal of having the shell
user-friendly enough to use, but without having extra functionality that
would hinder either the shell's start-up or prompt displaying time. I do
most of my programming and file editing in Mitsuharu Yamamoto's [Emacs
macOS port] (see [my .emacs.d], separate from this repository) or in
[IntelliJ IDEA]; using rich IDEs is another reason for the rather
bare-bones shell setup I prefer.

I mainly use macOS, so the tools are optimized for that
environment. Rudimentary support for Linux is in place, however, since I
occasionally work in a Linux environment for longer periods.

I have copied or adapted some contents from others. For small chunks of
code, I have embedded the source URL in a comment inside the file. When
copying has been extensive, I have retained the original copyright in
the file. Thank you all!

Finally, my motivation for using Bash over more feature-rich shells is
that I think tuning [.bashrc](.bashrc) helps keeping my shell
programming skills in shape.

## Setup highlights

A screenshot from [iTerm2], showing the Bash prompt:

<img src="https://github.com/tkareine/dotfiles/raw/master/images/bash-prompt-iterm2-input.png" title="My Bash prompt in iTerm2" alt="My Bash prompt in iTerm2" width="584">

The font in use is [Input][Input font]
([customization](https://input.fontbureau.com/download/index.html?size=14&language=python&theme=solarized-dark&family=InputMono&width=300&weight=400&line-height=1.1&a=ss&g=ss&i=serifs_round&l=serifs_round&zero=0&asterisk=height&braces=straight&preset=consolas&customize=please)).

### Fast Bash start-up and prompt display time

I get frustrated if the shell feels sluggish to use. That's why I
optimize the start-up time of my `.bashrc`:

``` bash
time bash --login -i -c true
# => real 0m0.276s
```

And especially, I want that the shell prompt gets re-displayed quickly:

``` bash
time eval "$PROMPT_COMMAND"
# => real 0m0.018s
```

### Show selected versions of programming environments in Bash prompt

The Bash prompt shows the currently selected versions of

* [Node.js], using [chnode] (`n:$version` at the top of the prompt),
* [Ruby], using [chruby] (`r:$version`), and
* [Java Development Kit], using a tiny shell function called `chjava`
  (`j:$version`).

For all these programming environments, I want that the environment
switching tool (such as chnode) selects the environment version for a
shell session. That allows using two different versions of Node.js in
separate shells simultaneously.

### macOS configuration

The [.macos](.macos) script configures macOS quite extensively,
considering what's possible with the `defaults` tool and plist files.

The script is originally based on [Mathias Bynens' .macos] script.

### GNU Global configuration

When you configure [GNU Global] to use [Universal Ctags] as a symbol
parser, it's possible to extend the functionality of Global with the
regex based [parser definition language][universal-ctags-optlib] of
Ctags. For instance, I've added extra support for Yaml, JavaScrip, SCSS,
and Less files. See [.globalrc](.globalrc) and
[custom.ctags](.ctags.d/custom.ctags).

The downside of regexes is that they're hard to maintain. That's why
there's an extensive test suite in [gtags-test.sh](test/gtags-test.sh).

Installing Global with Homebrew:

``` bash
brew install global
```

## Installation

Install the dotfiles with `./install.sh`, which either symlinks or
copies each file to your home directory. Installation is safe by
default: if the target file exists in your home directory already, the
installer skips symlinking or copying. See `./install -h` for more.

### Homebrew

On macOS, [install Homebrew][Homebrew install] to the default path
(`/usr/local`):

``` bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Bash

Installing the latest version of Bash, using [Homebrew] on macOS:

``` bash
brew install bash
sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
chsh -s /usr/local/bin/bash
```

## Xcode Zenburn color theme

I have adapted Bozhidar Batsov's [Emacs Zenburn] color theme for Xcode:

<img src="https://github.com/tkareine/dotfiles/raw/master/images/xcode-tkareine-zenburn-input.png" title="Zenburn color theme for Xcode" alt="Zenburn color theme for Xcode" width="688">

I prefer to use [Input font] for Xcode's source editor view, but you can
change the font with ease: in Xcode's Preferences → Fonts & Colors →
tkareine-zenburn → Source Editor, select all the list items with Cmd+A
and click on the font icon at the bottom to select another font for all
the items.

For installing the theme manually, copy
`Library/Developer/Xcode/UserData/FontAndColorThemes/tkareine-zenburn.dvtcolortheme`
file to `~/Library/Developer/Xcode/UserData/FontAndColorThemes/`
directory.

[Jari Nurminen](http://kippura.org/zenburnpage/) invented the theme
originally.

[Emacs Zenburn]: https://github.com/bbatsov/zenburn-emacs
[Emacs macOS port]: https://bitbucket.org/mituharu/emacs-mac/src/master/
[GNU Bash]: https://www.gnu.org/software/bash/
[GNU Global]: https://www.gnu.org/software/global/
[Homebrew install]: https://docs.brew.sh/Installation
[Homebrew]: https://brew.sh/
[Input font]: http://input.fontbureau.com/
[IntelliJ IDEA]: https://www.jetbrains.com/idea/
[Java Development Kit]: https://openjdk.java.net/
[Mathias Bynens' .macos]: https://github.com/mathiasbynens/dotfiles/blob/master/.macos
[Node.js]: https://nodejs.org/en/
[Ruby]: https://www.ruby-lang.org/
[chnode]: https://github.com/tkareine/chnode
[chruby]: https://github.com/postmodern/chruby
[universal-ctags-optlib]: https://docs.ctags.io/en/latest/man/ctags-optlib.7.html
[dotfiles-CI]: https://github.com/tkareine/dotfiles/actions?workflow=CI
[iTerm2]: https://www.iterm2.com/
[my .emacs.d]: https://github.com/tkareine/emacs.d
[Universal Ctags]: https://docs.ctags.io/en/latest/
