# dotfiles_copy
Copies dotfiles to and from a git repo :D

Usage:

    dotfiles_copy.pl -file .vimrc --push --save

    dotfiles_copy.pl --pull

    dotfiles_copy.pl --help

Options:

    push
        Copy/Push local dotfiles to rpeo

    pull
        Pull/Update local dotfiles from repo

    file
        Give multiple times for multiple files, Files to copy, can also be given in config_file

    config_file
        Path to config file, optional, defaults to 'dotfiles_copy.json' in
        the same directory as this app.

    git_url
        The repo, can also be given in config

    dir_name
        Where the repo is, by default ~/.dotfiles

    save
        Save given options to config.

