#!/bin/sh

CODENAME=$(lsb_release --codename | cut -f2)

apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
add-apt-repository ppa:neovim-ppa/stable

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${CODENAME} stable"

apt-get update
apt-get install -y stow zsh tmux htop alacritty neovim docker-ce code

usermod -aG docker "${USER}"

su - "${USER}"
