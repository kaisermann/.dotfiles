#!/bin/bash
packages=(
  diff-so-fancy
  npm-check-updates
  speed-test
)

for package in ${packages[*]}; do
  npm i -g $package
done
