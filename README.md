#  dotfiles

## Requirements

Set zsh as your login shell:

    chsh -s $(which zsh)

## Install

Clone onto your laptop:

    git clone git@github.com:ealvar3z/dotfiles.git ~/dotfiles

Install GNU stow from your package manager:

   sudo apt install stow

Install the dotfiles:

    cd $HOME/dotfiles/
    stow $PKG (eg. bash, tmux, zsh, etc)

This command will create symlinks for config files in your home directory.
If you need help `man stow` or see [blog here:](https://www.jakewiesler.com/blog/managing-dotfiles#understanding-stow)

## Thanks

![thoughtbot](https://thoughtbot.com/brand_assets/93:44.svg)

## License

Redistributed under the terms specified in the [`LICENSE`] file.

[`LICENSE`]: /LICENSE

