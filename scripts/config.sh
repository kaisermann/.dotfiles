#!/bin/bash
paths=(
  fish/fishfile
  fish/abbrs.fish
  fish/config.fish
  fish/path.fish
  fish/conf.d/til.fish
  # omf/pkg/til
  # omf/bundle
)

for path in ${paths[*]}; do
  mkdir -p ~/.config/$(dirname $path)
  ln -svf $(realpath ../content/config)/$path ~/.config/$(dirname $path)/
done

