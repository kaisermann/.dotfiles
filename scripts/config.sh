#!/bin/bash
paths=(
  fish/init.fish
  omf/pkg/til
  omf/bundle
)

for path in ${paths[*]}; do
  mkdir -p ~/.config/$(dirname $path)
  ln -svf $(dirname $(pwd))/content/config/$path ~/.config/
done

