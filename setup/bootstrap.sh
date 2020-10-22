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
  sudo add-apt-repository ppa:mmstick76/alacritty
}

install_clojure() {
  LEIN=$HOME/.bin/lein
  BOOT=$HOME/.bin/boot

  curl -sSLo $LEIN https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
  chmod +x $LEIN

  curl -sSLo $BOOT https://github.com/boot-clj/boot-bin/releases/download/latest/boot.sh
  chmod +x $BOOT

  curl -sSL https://download.clojure.org/install/linux-install-1.10.1.536.sh | sudo bash
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
  git remote set-url origin git@github.com:siriniok/dotfiles.git
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

config_tmux() {
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

packages=(
  cowsay
  emacs
  fzf
  git
  htop
  httpie
  jq
  neovim
  mc
  nyancat
  pgcli
  postgresql
  rlwrap
  tig
  tmux
  tree
  wget
  unrar
)

linux_packages=(
  alacritty
  caffeine
  clipit
  build-essential
  default-jdk
  font-manager
  fonts-firacode
  fonts-powerline
  gitg
  gimp
  gnome-shell-pomodoro
  google-chrome-stable
  gparted
  grub-customizer
  inkscape
  libpq-dev
  lm-sensors
  openjdk-14-jre
  openjdk-14-jdk
  python3-pip
  redshift-gtk
  silversearcher-ag
  unity-tweak-tool
  vim
  vim-gtk
  vlc
  wine-stable
  zsh
  xclip
)

snap_apps=(
  ngrok
  postbird
  postman
  telegram-desktop
  wps-office
)

snap_classic_apps=(
  code
  heroku
  skype
)

mac_packages=(
  boot-clj
  certbot
  clojure/tools/clojure
  fabianishere/personal/pam_reattach
  gnupg
  heroku
  leiningen
  macvim
  openjdk
  python@3.8
  the_silver_searcher
)

mac_cask_packages=(
  alacritty
  coconutbattery
  clipy
  dash
  font-fira-code
  gh
  inkscape
  iterm2
  lastpass
  macs-fan-control
  marvin
  mcgimp
  ngrok
  postbird
  postman
  psequel
  qlcolorcode
  qlstephen
  qlmarkdown
  quicklook-json
  qlimagesize
  suspicious-package
  quicklookase
  qlvideo
  skype
  spotify
  sourcetree
  visual-studio-code
  vlc
  the-unarchiver
  zoomus
  zotero
  google-chrome
)

mac_tap_packages=(
  homebrew/cask-fonts
  heroku/brew
)

if [ $(uname) = 'Linux' ]; then
  info "Adding package sources"
  add_package_sources

  info "Retrieving new lists of packages"
  sudo apt-get update

  info "Installing latest apps"
  sudo apt-get install -y -qq ${packages[@]} ${linux_packages[@]}

  info "Installing snap apps..."
  sudo snap install ${snap_apps[@]}

  info "Installing snap classic apps..."
  for app in "${snap_classic_apps[@]}"; do
    sudo snap install --classic $app
  done

  info "Changing shell to ZSH"
  chsh -s $(which zsh) || error "Error: Cannot set zsh as default shell!"

  info "Install clojure"
  install_clojure

  info "Upgrading Ubuntu"
  sudo apt-get upgrade -y

  sudo apt-get autoremove
  sudo apt-get autoclean
elif [[ `uname` == 'Darwin' ]]; then
  info "Installing Homebrew"
  install_homebrew

  info "Installing latest apps"
  for app in "${mac_tap_packages[@]}"; do
    brew tap $app
  done
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

info "Configuring tmux"
config_tmux

popd

success "Success! Please restart your PC!"

catpick

exit $EXIT_SUCCESS
