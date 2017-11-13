# Vladyslav Siriniok's Dotfiles

[![Gitter](https://badges.gitter.im/siriniok/dotfiles.svg)](https://gitter.im/siriniok)

## Installation

Install the Dotfiles

```
curl --silent https://raw.githubusercontent.com/siriniok/dotfiles/master/setup/install.sh | sh
```

This repo contains a Rakefile that does some magic things:

* `rake` - symlink all dotfiles
* `rake setup_file[.file1 .file2]` - symlink specific files

## Structure

* `bin` - miscellaneous scripts. Will be added to your `$PATH`
* `editors` - files for different text editors
    * `sublime` - files for Sublime Text 3
    * `vim` - files for Vim
* `tilde` - files for symlinking to your `$HOME` directory
* `setup` - different setup scripts
* `zsh` - my custom Zsh files

## Resources & Inspiration

### Shell Scripting

* [A Beginner’s Guide to the Best Command Line Tools](https://webdevstudios.com/2015/02/10/a-beginners-guide-to-the-best-command-line-tools/)
* [Bash Handbook](https://github.com/denysdovhan/bash-handbook)
* [Defensive BASH Programming](http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming)
* [Hints for Writing Unix Tools](https://monkey.org/~marius/unix-tools-hints.html)
* [Unix Toolbox](http://cb.vu/unixtoolbox.xhtml)

### Tmux & Text Editors

Vim Cheat Sheets ([First](http://www.viemu.com/a_vi_vim_graphical_cheat_sheet_tutorial.html) | [Second](http://www.fprintf.net/vimCheatSheet.html))

Emacs Cheat Sheets ([First](http://sachachua.com/blog/wp-content/uploads/2013/05/How-to-Learn-Emacs8.png) | [Survival](https://www.gnu.org/software/emacs/refcards/pdf/survival.pdf) | [Refcard](https://www.gnu.org/software/emacs/refcards/pdf/refcard.pdf))

* [Vim for Humans](https://vimebook.com/)
* [Practical Vim](https://pragprog.com/book/dnvim2/practical-vim-second-edition)
* [Walkthrough of my .vimrc file for Ruby development](http://janjiss.com/walkthrough-of-my-vimrc-file-for-ruby-development/)
* [Coming Home to Vim](http://stevelosh.com/blog/2010/09/coming-home-to-vim/#some-background-about-me)
* [Vim and Ctags](https://andrew.stwrt.ca/posts/vim-ctags/)
* [Vim: revisited](http://mislav.net/2011/12/vim-revisited/)
* [Vim anti-patterns](https://sanctum.geek.nz/arabesque/vim-anti-patterns/)
* [Remote Pair Programming Made Easy with SSH and tmux](http://www.hamvocke.com/blog/remote-pair-programming-with-tmux/)

### Dotfiles

* [GitHub ❤ ~/ - Your unofficial guide to dotfiles on GitHub](https://dotfiles.github.io/)
* [Brad Parbs's Dotfiles](https://github.com/bradp/dotfiles)
* [Paul Miller's Dotfiles](https://github.com/paulmillr/dotfiles)
* [Ben Alman's Dotfiles](https://github.com/cowboy/dotfiles)
* [Denys Dovhan's Dotfiles](https://github.com/denysdovhan/dotfiles)

## Tools

* [pgcli](https://www.pgcli.com/) - a CLI for Postgres with auto-completion and syntax highlighting
* [jq](https://stedolan.github.io/jq/) - a lightweight and flexible command-line JSON processor
* [ranger](http://ranger.nongnu.org/) - a console file manager with Vi keybindings

## License

[MIT](https://github.com/siriniok/dotfiles/blob/master/LICENSE) (c) 2015-2016 Vladyslav Siriniok (http://siriniok.com)
