#bin/sh

for crate in exa bat fd-find ripgrep
do
  cargo install $crate
done
