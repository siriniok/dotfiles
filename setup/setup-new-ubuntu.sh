#!/bin/sh

# Ask for password
sudo -v

echo "Updating APT"
sudo apt-get update

echo "Updating Ubuntu"
sudo apt-get dist-upgrade
sudo apt-get upgrade

echo "Updating APT"
sudo apt-get update

# Packages
packages=(
  gimp
  xclip
)

echo "Installing apps with apt-get..."
sudo apt-get install ${apps[@]}

sudo apt-get clean

echo "Done!"
