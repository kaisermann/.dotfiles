#!/bin/bash
paths=(
  .exiftool_config
  .gitconfig
  .gitignore.global
  .dircolors
  .vimrc
  .vim
)

for path in ${paths[*]}; do
  mkdir -p ~/$(dirname $path)
  ln -svf $(realpath $(dirname $0)/../content/home)/$path ~/$(dirname $path)/
done
