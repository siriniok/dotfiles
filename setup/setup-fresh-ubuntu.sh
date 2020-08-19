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
  cowsay "Done!"
}

# Helpers
add_package_sources() {
  sudo add-apt-repository ppa:mmstick76/alacritty
}

config_system() {
  echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
  sudo sensors-detect
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

if [ $(uname) = 'Linux' ]; then
  info "Adding package sources"
  add_package_sources

  info "Retrieving  new lists of packages"
  sudo apt-get update

  packages=(
    alacritty
    caffeine
    clipit
    default-jdk
    emacs
    exuberant-ctags
    font-manager
    fzf
    gimp
    gitg
    gnome-shell-pomodoro
    gparted
    grub-customizer
    httpie
    htop
    inkscape
    jq
    lm-sensors
    libpq-dev
    mc
    nyancat
    openjdk-14-jre
    openjdk-14-jdk
    pgadmin3
    pgcli
    playonlinux
    postgresql
    postgresql-contrib
    redshift-gtk
    rlwrap
    silversearcher-ag
    steam-installer
    tig
    tmux
    tree
    unetbootin
    unrar
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

  info "Configuring system"
  config_system

  info "Install clojure"
  install_clojure

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
