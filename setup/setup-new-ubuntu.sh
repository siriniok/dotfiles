#!/bin/bash

# Apps
apps=(
  gimp
  xclip
)

echo "Installing apps with apt-get..."
sudo apt-get install ${apps[@]}

sudo apt-get clean

echo "Done!"
