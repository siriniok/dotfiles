#!/usr/bin/env bash

# Dotfiles and bootstrap installer
# Works on macOS Monterey 12.2+

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

install_homebrew() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
}

install_ruby() {
  eval "$(frum init)"
  frum install 3.2.0
  frum global 3.2.0
  gem install rake
}

install_node() {
  eval "$(fnm env --use-on-cd)"
  fnm install 19.4
  fnm use 19.4
  fnm default 19.4
}

install_rust() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

install_dotfiles() {
  git clone https://github.com/siriniok/dotfiles.git $DOTFILES_DIR
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
  git clone https://github.com/mroth/evalcache ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/evalcache
}

config_vim() {
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  mkdir ~/.vim/backup ~/.vim/swap ~/.vim/undo ~/.vim/session
}

config_tmux() {
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

config_xcode() {
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  sudo xcodebuild -runFirstLaunch
}

config_android() {
  sdkmanager --install "cmdline-tools;latest"
}

tap_packages=(
  homebrew/cask-fonts
)

packages=(
  Azure/kubelogin/kubelogin
  awscli
  azure-cli
  bat
  borkdude/brew/babashka
  borkdude/brew/clj-kondo
  certbot
  cloc
  clojure-lsp/brew/clojure-lsp-native
  clojure/tools/clojure
  cowsay
  exa
  fabianishere/personal/pam_reattach
  fd
  fnm
  frum
  fzf
  gh
  git
  git-crypt
  gnupg
  htop
  httpie
  hwloc
  jq
  kubernetes-cli
  leiningen
  maven
  mc
  mtr
  neovim
  nyancat
  pgcli
  postgresql@14
  pstree
  python@3.11
  ripgrep
  rlwrap
  saulpw/vd/visidata
  terraform
  tig
  tmux
  tree
  wget
)

cask_packages=(
  1password
  alacritty
  android-file-transfer
  android-studio
  beeper
  clipy
  cloudflare-warp
  coconutbattery
  dash
  docker
  emacs
  figma
  firefox
  flutter
  font-fira-code
  font-fira-code-nerd-font
  gitup
  google-chrome
  google-cloud-sdk
  google-drive
  inkscape
  iterm2
  macs-fan-control
  macvim
  marvin
  mcgimp
  microsoft-edge
  ngrok
  postbird
  postman
  superlist
  qlcolorcode
  qlimagesize
  qlmarkdown
  qlstephen
  qlvideo
  quicklook-json
  quicklookase
  rar
  signal
  skype
  sourcetree
  spotify
  superlist
  suspicious-package
  telegram
  temurin
  the-unarchiver
  tor-browser
  typora
  visual-studio-code
  vlc
  zoom
  zotero
)

if  [[ `uname` == 'Darwin' ]]; then
  info "Installing Homebrew"
  install_homebrew

  info "Installing latest apps"
  for app in "${tap_packages[@]}"; do
    brew tap $app
  done
  brew install ${packages[@]} ${packages[@]}
  brew install --cask ${cask_packages[@]}
else
  error "Error: Your OS is not macOS."
  exit $EXIT_FAILURE
fi

info "Installing the dotfiles"
install_dotfiles

info "Installing NodeJS"
install_node

info "Installing Ruby"
install_ruby

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

info "Configuring Xcode"
config_xcode

info "Configuring Android development"
config_android

popd

success "Success! Please restart your PC!"

catpick

exit $EXIT_SUCCESS
