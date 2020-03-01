#!/usr/bin/env bash

# Prepares fresh Ubuntu install for work
# Run after the install.sh script
# Works on Ubuntu 18.04+

# Ask for password
sudo -v

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
  sudo add-apt-repository ppa:mmstick76/alacritty
}

install_oh_my_zsh() {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

install_omz_plugins() {
  git clone https://github.com/TamCore/autoupdate-oh-my-zsh-plugins ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autoupdate
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
}

add_ssh_keys() {
  ssh-keygen -t rsa -b 4096 -C "siriniok@gmail.com"
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_rsa
  xclip -sel clip < ~/.ssh/id_rsa.pub
}

config_vim() {
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  mkdir ~/.vim/backup ~/.vim/swap ~/.vim/undo ~/.vim/session
}

config_tmux() {
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

config_system() {
  echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
  sudo sensors-detect
}

if [ $(uname) = 'Linux' ]; then
  info "Adding package sources"
  add_package_sources

  info "Retrieving  new lists of packages"
  sudo apt-get update

  packages=(
    alacritty
    caffeine
    clipit
    cowsay
    default-jdk
    emacs
    exuberant-ctags
    fonts-powerline
    fzf
    gimp
    gitg
    gnome-shell-pomodoro
    gparted
    grub-customizer
    httpie
    inkscape
    jq
    lm-sensors
    mc
    nyancat
    pgadmin3
    pgcli
    playonlinux
    postgresql
    postgresql-contrib
    redshift-gtk
    silversearcher-ag
    steam-installer
    tig
    tmux
    tree
    unetbootin
    unrar
    neovim
    vim
    vim-gtk
    vlc
    wine-stable
    xclip
  )

  snap_apps=(
    gitkraken
    ngrok
    postman
    telegram-desktop
    wps-office
  )

  snap_classic_apps=(
    code
    heroku
    skype
  )

  info "Installing apps with apt-get..."
  sudo apt-get install -y -qq ${packages[@]}

  info "Installing snap apps..."
  sudo snap install ${snap_apps[@]}

  info "Installing snap classic apps..."
  for app in "${snap_classic_apps[@]}"; do
    sudo snap install --classic $app
  done

  info "Installing Oh My ZSH"
  install_oh_my_zsh
  info "Installing Oh My ZSH plugins"
  install_omz_plugins

  info "Adding SSH keys"
  add_ssh_keys
  success "SSH keys were copied to the clipboard"

  info "Configuring Vim"
  config_vim

  info "Configuring tmux"
  config_tmux

  info "Configuring system"
  config_system

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
