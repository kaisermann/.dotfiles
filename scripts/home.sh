#!/bin/bash
paths=(
  .exiftool_config
  .gitconfig
  .gitignore.global
  .bash_profile
  .bashrc
  .dircolors
  .vimrc
  .vim
)

for path in ${paths[*]}; do
  mkdir -p ~/$(dirname $path)
  ln -svf $(dirname $(pwd))/content/home/$path ~/
done

open -e ~/.gitconfig
