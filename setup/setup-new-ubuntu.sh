#!/bin/sh

# Ask for password
sudo -v

sudo add-apt-repository ppa:danielrichter2007/grub-customizer

echo "Updating APT"
sudo apt-get update

# Packages
packages=(
  build-essential
  clipit
  caffeine
  cowsay
  httpie
  gimp
  grub-customizer
  inkscape
  gparted
  unetbootin
  vlc
  mc
  python-pip
  redshift
  silversearcher-ag
  tig
  tree
  )

echo "Installing apps with apt-get..."
sudo apt-get install -y -qq ${apps[@]}

wget -qO- https://cli-assets.heroku.com/install-ubuntu.sh | sh

sudo apt-get autoremove
sudo apt-get autoclean

echo "Done!"
