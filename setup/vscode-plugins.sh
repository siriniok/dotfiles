#!/usr/bin/env bash

# Visual Studio Code :: Package list
plugins=(
  ms-vsliveshare.vsliveshare
  pnp.polacode
  vscodevim.vim
  bradlc.vscode-tailwindcss
)

for plugin in ${plugins[@]}; do
  code --install-extension $plugin
done
