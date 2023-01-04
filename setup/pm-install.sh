#!/usr/bin/env bash

# Reporters for bash scripts
e='\033'
RESET="${e}[0m"
BOLD="${e}[1m"
CYAN="${e}[0;96m"
RED="${e}[0;91m"
YELLOW="${e}[0;93m"
GREEN="${e}[0;92m"

# Success reporter
info() {
  echo ; echo -e "${CYAN}${BOLD}${*}${RESET}" ; echo
}

# Error reporter
error() {
  echo ; echo -e "${RED}${BOLD}${*}${RESET}" ; echo
}

# Success reporter
success() {
  echo ; echo -e "${GREEN}${BOLD}${*}${RESET}" ; echo
}

# Final catpick
catpick() {
  echo
  echo -e -n $RED'-_-_-_-_-_-_-_'
  echo -e    $RESET$BOLD',------,'$RESET
  echo -e -n $YELLOW'_-_-_-_-_-_-_-'
  echo -e    $RESET$BOLD'|   /\_/\\'$RESET
  echo -e -n $GREEN'-_-_-_-_-_-_-'
  echo -e    $RESET$BOLD'~|__( ^ .^)'$RESET
  echo -e -n $CYAN'-_-_-_-_-_-_-_-'
  echo -e    $RESET$BOLD'""  ""'$RESET
  echo
}

ruby_packages=(
  bundle
  cocoapods
  foreman
  neovim
  rails
  standardrb
  solargraph
)

npm_packages=(
  create-react-app
  javascript-typescript-langserver
  neovim
  pgsh
  standard
  tldr
  yarn
)

pip_packages=(
  pynvim
  neovim-remote
  msgpack
  trash-cli
  vim-vint
)

cargo_packages=(
)

info "Installing global Ruby packages"
gem install ${ruby_packages[@]}

info "Installing global NPM packages"
npm install -g ${npm_packages[@]}

if [ -n "$pip_packages" ]; then
  info "Installing global pip3 packages"
  python3 -m pip install --user --upgrade ${pip_packages[@]}
fi

if [ -n "$cargo_packages" ]; then
  info "Installing global cargo packages"
  cargo install ${cargo_packages[@]}
fi

catpick
