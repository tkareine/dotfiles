My dotfiles. They're here so that I can synchronize them across
computers I work with.

Install the dotfiles with `./install.sh`, which either symlinks or
copies each file to your home directory. Installation is safe by
default: if the target file exists in your home directory already, the
installer skips symlinking or copying. See `./install -h` for more.

XCode Zenburn color theme
-------------------------

I have adapted Bozhidar Batsov's
[Emacs Zenburn color theme](http://github.com/bbatsov/zenburn-emacs)
for XCode:

<img src="https://dl.dropboxusercontent.com/u/1404049/xcode-tkareine-zenburn.png" title="Zenburn color theme for XCode" alt="Zenburn color theme for XCode" width="725" height="734">

I prefer to use
[Inconsolata](http://www.levien.com/type/myfonts/inconsolata.html)
font for XCode's source editor view, but you can change the font with
ease: in XCode's Preferences → Fonts & Colors → tkareine-zenburn →
Source Editor, select all the list items with Cmd+A and click on the
font icon at the bottom to select another font for all the items.

The installer installs the theme. Alternatively, you can install the
theme manually by copying
`Library/Developer/Xcode/UserData/FontAndColorThemes/tkareine-zenburn.dvtcolortheme`
to `~/Library/Developer/Xcode/UserData/FontAndColorThemes/` directory.

[Jari Nurminen](http://kippura.org/zenburnpage/) invented the theme
originally.

Thanks
------

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
