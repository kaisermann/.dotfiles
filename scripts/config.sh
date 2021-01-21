#!/bin/bash
paths=(
  fish/fish_plugins
  fish/abbrs.fish
  fish/config.fish
  fish/path.fish
  fish/conf.d/til.fish
)

for path in ${paths[*]}; do
  mkdir -p ~/.config/$(dirname $path)
  ln -svf $(realpath $(dirname $0)/../content/config)/$path ~/.config/$(dirname $path)
done

