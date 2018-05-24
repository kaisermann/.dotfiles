#!/bin/bash
paths=(
  fish/init.fish
  omf/pkg/til
  omf/bundle
)

for path in ${paths[*]}; do
  mkdir -p ~/.config/$(dirname $path)
  ln -svf $(readlink -f ../content/config)/$path ~/.config/
done

