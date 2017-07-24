# dotfiles_copy
Copies dotfiles to and from a git repo :D

Usage:

    dotfiles_copy.pl -files .vimrc --copy --save

    dotfiles_copy.pl --update

    dotfiles_copy.pl --help

Options:

    copy
        Copy local dotfiles to rpeo

    update
        Update local dotfiles from repo

    files
        Files to copy, can also be given in config_file

    config_file
        Path to config file, optional, defaults to 'dotfiles_copy.json' in
        the same directory as this app.

    git_url
        The repo, can also be given in config

    dir_name
        Where the repo is, by default ~/.dotfiles

    save
        Save given options to config.

