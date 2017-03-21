My dotfiles. They're here so that I can synchronize them across
computers I work with.

Install the dotfiles with `./install.sh`, which either symlinks or
copies each file to your home directory. Installation is safe by
default: if the target file exists in your home directory already, the
installer skips symlinking or copying. See `./install -h` for more.

# Xcode Zenburn color theme

I have adapted Bozhidar Batsov's
[Emacs Zenburn color theme](http://github.com/bbatsov/zenburn-emacs) for
Xcode:

<img src="https://github.com/tkareine/dotfiles/raw/master/images/xcode-tkareine-zenburn-input.png" title="Zenburn color theme for Xcode" alt="Zenburn color theme for Xcode" width="688">

I prefer to use [Input](http://input.fontbureau.com/) font (with these
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

# Thanks

I have copied or adapted the contents of some of the files from other
people. For small chunks of code, I have embedded the source URL in a
comment inside the file. When copying has been extensive, I have
retained the original copyright in the file.

Thanks for:

* `.irbrc`, containing code adapted from
  [Chris Wanstrath](http://ozmm.org/posts/time_in_irb.html) and
  [Ryan Tomayko](https://github.com/rtomayko/dotfiles/blob/rtomayko/.irbrc)
* `.osx`, adapted from [Mathias Bynens](http://mths.be/osx)
* `bin/git-remote-hg`, written by
  [Felipe Contreras](https://github.com/felipec/git-remote-hg)

Feel free to copy dotfiles further, as long as you respect original
copyrights and licensing.
