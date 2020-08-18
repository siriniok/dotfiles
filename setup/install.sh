#!/usr/bin/env bash

# Dotfiles and bootstrap installer
# Installs git, clones repository and symlinks dotfiles to your home directory
# Works on Ubuntu 20.04+ and macOS Catalina 10.15+

# Ask for password
sudo -v

WORK_DIR="$HOME/Work"
DOTFILES_DIR="$HOME/Work/.dotfiles"
pushd .
mkdir -p $WORK_DIR
cd $WORK_DIR

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
  echo ; echo  -e "${GREEN}${BOLD}${*}${RESET}" ; echo
}

# Final catpick
catpick() {
  cowsay "Done!"
}

# Helpers
add_package_sources() {
  # Google Chrome
  wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
}

install_rvm() {
  gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  curl -sSL https://get.rvm.io | bash -s stable --ruby --gems=bundler,rake --ignore-dotfiles
}

install_node() {
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
  source ~/.zlogin
  nvm install node
  nvm use node
  npm install -g yarn
}

install_rust() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

install_homebrew() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
}

install_dotfiles() {
  git clone git://github.com/siriniok/dotfiles.git $DOTFILES_DIR
  pushd .
  cd $DOTFILES_DIR
  rake install
  popd
}

install_oh_my_zsh() {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

install_omz_plugins() {
  git clone https://github.com/TamCore/autoupdate-oh-my-zsh-plugins ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autoupdate
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
}

config_vim() {
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  mkdir ~/.vim/backup ~/.vim/swap ~/.vim/undo ~/.vim/session
}

packages=(
  cowsay
  neovim
  wget
)

linux_packages=(
  build-essential
  fonts-powerline
  git
  google-chrome-stable
  python3-pip
  unity-tweak-tool
  vim
  vim-gtk
  zsh
)

mac_packages=(
  gnupg
  python@3.8
  macvim
)

mac_cask_packages=(
  google-chrome
)

if [ $(uname) = 'Linux' ]; then
  info "Adding package sources"
  add_package_sources

  info "Retrieving new lists of packages"
  sudo apt-get update

  info "Installing latest apps"
  sudo apt-get install -y -qq ${packages[@]} ${linux_packages[@]}

  info "Changing shell to ZSH"
  chsh -s $(which zsh) || error "Error: Cannot set zsh as default shell!"

  sudo apt-get autoremove
  sudo apt-get autoclean
elif [[ `uname` == 'Darwin' ]]; then
  info "Installing Homebrew"
  install_homebrew

  info "Installing latest apps"
  brew install ${packages[@]} ${mac_packages[@]}
  brew cask install ${mac_cask_packages[@]}
else
  error "Error: Your OS is not Linux or macOS."
  exit $EXIT_FAILURE
fi

info "Installing RVM and Ruby"
install_rvm

info "Installing the dotfiles"
install_dotfiles

info "Installing NVM and NodeJS"
install_node

info "Installing Rust"
install_rust

info "Installing Oh My ZSH"
install_oh_my_zsh

info "Installing Oh My ZSH plugins"
install_omz_plugins

info "Configuring Vim"
config_vim

popd

success "Success! Please restart your PC!"

catpick

exit $EXIT_SUCCESS
