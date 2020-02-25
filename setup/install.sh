#!/usr/bin/env bash

# Dotfiles and bootstrap installer
# Installs git, clones repository and symlinks dotfiles to your home directory
# Works on Ubuntu 18.04+

# Ask for password
sudo -v

DOTFILES_DIR="$HOME/.dotfiles"

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

# Helpers
add_package_sources() {
  # Google Chrome
  wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
}

install_rvm() {
  gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  curl -sSL https://get.rvm.io | bash -s stable --ruby --gems=bundler,rake --ignore-dotfiles
  ~/.rvm/scripts/rvm
  type rvm | head -n 1
}

install_node() {
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
  source ~/.zlogin
  nvm install node
  nvm use node
  npm install -g yarn
}

install_dotfiles() {
  git clone git://github.com/siriniok/dotfiles.git $DOTFILES_DIR
  cd $DOTFILES_DIR
  rake install
  cd $HOME
}

if [ $(uname) = 'Linux' ]; then
  info "Adding package sources"
  add_package_sources

  info "Retrieving new lists of packages"
  sudo apt-get update

  packages=(
    build-essential
    git
    zsh
    google-chrome-stable
    unity-tweak-tool
  )

  info "Installing latest git, zsh and dependencies..."
  sudo apt-get install -y -qq ${packages[@]}

  info "Changing shell to ZSH"
  chsh -s $(which zsh) || error "Error: Cannot set zsh as default shell!"

  info "Installing RVM and Ruby"
  install_rvm

  info "Installing NVM and NodeJS"
  install_node

  info "Installing the dotfiles"
  install_dotfiles

  info "Upgrading Ubuntu"
  sudo apt-get upgrade -y

  sudo apt-get autoremove
  sudo apt-get autoclean

  success "Success! Please restart your PC!"

  catpick

  exit $EXIT_SUCCESS
else
  error "Error: Your OS is not Linux."
  exit $EXIT_FAILURE
fi
