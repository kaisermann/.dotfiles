#!/bin/bash
paths=(
  fish/fishfile
  fish/abbrs.fish
  fish/config.fish
  fish/path.fish
  fish/conf.d/til.fish
  fish/conf.d/vtex.fish
)

for path in ${paths[*]}; do
  mkdir -p ~/.config/$(dirname $path)
  ln -svf $(realpath $(dirname $0)/../content/config)/$path ~/.config/$(dirname $path)
done

