# My dotfiles

[![CI](https://github.com/tkareine/dotfiles/actions/workflows/ci.yml/badge.svg)][dotfiles-CI]

Here is my public configuration for selected command line tools. I
checkout this repository to computers I work with.

The dotfiles focus on [GNU Bash] with the goal of having the shell
user-friendly enough to use, but without having extra functionality that
would hinder either the shell's start-up or prompt displaying time. I do
most of my programming and file editing in [Emacs] (see [my .emacs.d],
separate from this repository) or in [IntelliJ IDEA]; using rich IDEs is
another reason for the rather bare-bones shell setup I prefer.

I mainly use macOS, so the tools are optimized for that environment.
Rudimentary support for Linux is in place, however, since I occasionally
work in a Linux environment for longer periods.

I have copied or adapted some contents from others. For small chunks of
code, I have embedded the source URL in a comment inside the file. When
copying has been extensive, I have retained the original copyright in
the file. Thank you all!

Finally, my motivation for using Bash over more feature-rich shells is
that I think tuning [.bashrc](.bashrc) helps keeping my shell
programming skills in shape.

## Setup highlights

A screenshot from [iTerm2], showing the Bash prompt:

<img src="https://github.com/tkareine/dotfiles/raw/master/images/bash-prompt-showcase-iterm2-v2.png" title="Bash prompt showcase in iTerm2" alt="Bash prompt showcase in iTerm2" width="615">

The font in use is [Input][Input font]
([customization](https://input.djr.com/download/?customize&fontSelection=fourStyleFamily&regular=InputMonoNarrow-Regular&italic=InputMonoNarrow-Italic&bold=InputMonoNarrow-Bold&boldItalic=InputMonoNarrow-BoldItalic&a=ss&g=ss&i=serifs_round&l=serifs_round&zero=0&asterisk=height&braces=straight&preset=default&line-height=1.2)).

### Fast Bash start-up and prompt display time

I get frustrated if the shell feels sluggish to use. That's why I
optimize the start-up time of my `.bashrc`:

``` bash
time bash --login -i -c true
# real    0m0.162s
```

And especially, I want that the shell prompt gets re-displayed quickly.
In a directory not belonging to a Git working tree:

``` bash
time eval "$PROMPT_COMMAND"
# real    0m0.032s
```

The [.bashrc-support.sh](.bashrc-support.sh) file defines `tk_bm`, a
tiny shell function to benchmark the execution time of a command within
the shell itself. Using that to benchmark shell prompt:

``` bash
tk_bm 'eval "$PROMPT_COMMAND"'
# warmup for 1.150 secs (100 times)
# run command for 10.821 secs (1000 times): eval "$PROMPT_COMMAND"
# mean 10.821 ms
```

These outputs are from an Apple M2 Pro laptop, using Bash v5 and
[bash-completion] with completions enabled for around 30 different
tools.

### Show selected versions of programming environments in Bash prompt

The Bash prompt shows the currently selected versions of

* [Node.js], using [chnode] (`n:$version` at the top of the prompt),
* [Ruby], using [chruby] (`r:$version`), and
* [Java Development Kit], using a tiny shell function called `chjava`
  defined in [.bashrc-common.sh](.bashrc-common.sh) (`j:$version`).

For all these programming environments, I want that the environment
switching tool (such as chnode) selects the environment version for a
shell session. That allows using two different versions of Node.js in
separate shells simultaneously.

### macOS configuration

The [.macos.sh](.macos.sh) script configures macOS quite extensively,
considering what's possible with the `defaults` tool and plist files.

The script is originally based on [Mathias Bynens' .macos] script.

### GNU Global configuration

When you configure [GNU Global] to use [Universal Ctags] as a symbol
parser, it's possible to extend the functionality of Global with the
regex based [parser definition language][universal-ctags-optlib] of
Ctags. For instance, I've added extra support for Yaml, JavaScript,
SCSS, and Less files. See [.globalrc](.globalrc) and
[custom.ctags](.ctags.d/custom.ctags).

The downside of regexes is that they're hard to maintain. That's why
there's an extensive test suite in [gtags-test.sh](test/gtags-test.sh).

Installing Global with Homebrew:

``` bash
brew install global
```

### Test automation for dotfiles

Did you know you can automate testing your shell's init scripts? See
[bash-test.sh](test/bash-test.sh).

Tests are implemented on top of a small custom framework, written in
Bash. It was fun to write it. See the sources in the
[test/support](test/support/) directory.

Run `make` at the root of the project in order to learn how to run the
linters and tests.

## Installation

Install the dotfiles with `./install.sh`, which either symlinks or
copies each file to your home directory. Installation is safe by
default: if the target file exists in your home directory already, the
installer skips symlinking or copying. See `./install -h` for more.

### Homebrew

On macOS, [install Homebrew][Homebrew install] to its default prefix
directory:

``` bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Bash

Installing the latest version of Bash, using [Homebrew] on macOS:

``` bash
brew install bash
sudo bash -c "echo $(brew --prefix)/bin/bash >> /etc/shells"
chsh -s "$(brew --prefix)/bin/bash"
```

[Emacs]: https://www.gnu.org/software/emacs/
[GNU Bash]: https://www.gnu.org/software/bash/
[GNU Global]: https://www.gnu.org/software/global/
[Homebrew install]: https://docs.brew.sh/Installation
[Homebrew]: https://brew.sh/
[Input font]: https://input.djr.com/
[IntelliJ IDEA]: https://www.jetbrains.com/idea/
[Java Development Kit]: https://openjdk.java.net/
[Mathias Bynens' .macos]: https://github.com/mathiasbynens/dotfiles/blob/master/.macos
[Node.js]: https://nodejs.org/en/
[Ruby]: https://www.ruby-lang.org/
[Universal Ctags]: https://docs.ctags.io/en/latest/
[bash-completion]: https://github.com/scop/bash-completion
[chnode]: https://github.com/tkareine/chnode
[chruby]: https://github.com/postmodern/chruby
[dotfiles-CI]: https://github.com/tkareine/dotfiles/actions/workflows/ci.yml
[iTerm2]: https://www.iterm2.com/
[my .emacs.d]: https://github.com/tkareine/emacs.d
[universal-ctags-optlib]: https://docs.ctags.io/en/latest/man/ctags-optlib.7.html
