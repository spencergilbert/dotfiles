[![pipeline status](https://gitlab.com/spencergilbert/dotfiles/badges/master/pipeline.svg)](https://gitlab.com/spencergilbert/dotfiles/commits/master)

## Table of Contents
 - [Introduction](#Introduction)
 - [Managing](#Managing)
 - [Installing](#Installing)
 - [How It Works](#How It Works)

# Introduction

# Managing
I manage my configuration with [GNU Stow](https://www.gnu.org/software/stow/). Initially inspired by [this article](http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html), I've found this to be a simpler and more organic solution to configuration management and remote versioning.

# Installing
```
$ curl -sSL https://gitlab.com/spencergilbert/dotfiles/-/raw/master/install.sh | sh
```

# How It Works
Stow creates symlinks for files in the parent directory of where you execute it (by default). With this in mind, I keep this repo locally in my home directory `~/.dotfiles` and execute stow from within this directory. 

To install configurations simply use `stow <folder_name>`.

*NOTE:* stow will only create the symlink if the config file doesn't already exist. You can `rm` the file before using `stow`.

To load ZSH plugins (or load new plugins after editing `.zsh_plugins.txt`), simply run the below command.

```sh
antibody bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh
```

To remove configuration use the same command but pass the `-D` argument to `stow`.


