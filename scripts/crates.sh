#!/bin/sh

curl -sSf https://sh.rustup.rs | sh -s -- -y

for crate in exa bat fd-find ripgrep
do
  cargo install $crate
done
