#!/bin/bash
packages=(
  diff-so-fancy
  gulp-cli
  npm-check-updates
  speed-test
  yarn
  bolt
)

for package in ${packages[*]}; do
  npm i -g $package
done
