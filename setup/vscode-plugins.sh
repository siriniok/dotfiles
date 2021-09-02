#!/usr/bin/env bash

# Visual Studio Code :: Package list
plugins=(
  ms-vsliveshare.vsliveshare
  pnp.polacode
  vscodevim.vim
  bradlc.vscode-tailwindcss
  streetsidesoftware.code-spell-checker-ukrainian
  timonwong.shellcheck
  mechatroner.rainbow-csv
  ryu1kn.partial-diff
  howardzuo.vscode-npm-dependency
  DavidAnson.vscode-markdownlint
  yzhang.markdown-all-in-one
  eamodio.gitlens
  felipecaputo.git-project-manager
  dbaeumer.vscode-eslint
  EditorConfig.EditorConfig
  streetsidesoftware.code-spell-checker
  James-Yu.latex-workshop
)

for plugin in ${plugins[@]}; do
  code --install-extension $plugin
done
