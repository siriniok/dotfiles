#!/bin/sh

# Dotfiles and bootstrap installer
# Installs git, clones repository and symlinks dotfiles to your home directory

# Ask for password
sudo -v

e='\033'
RESET="${e}[0m"
BOLD="${e}[1m"
CYAN="${e}[0;96m"
RED="${e}[0;91m"
YELLOW="${e}[0;93m"
GREEN="${e}[0;92m"

# Success reporter
info() {
  echo ; echo "${CYAN}${BOLD}${*}${RESET}" ; echo
}

# Error reporter
error() {
  echo ; echo "${RED}${BOLD}${*}${RESET}" ; echo
}

# Success reporter
success() {
  echo ; echo "${GREEN}${BOLD}${*}${RESET}" ; echo
}

# Preinstall
if [ $(uname) = 'Linux' ]; then
  wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

  # Retrieve new lists of packages
  sudo apt-get update

  # Install latest git, zsh and ruby dependencies
  sudo apt-get install -y git zsh vim vim-gtk tmux xclip google-chrome-stable unity-tweak-tool

  gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  curl -sSL https://get.rvm.io | bash -s stable --ruby --gems=bundler,rake --ignore-dotfiles
  ~/.rvm/scripts/rvm

  git clone https://github.com/powerline/fonts.git --depth=1
  cd fonts
  ./install.sh
  cd ..
  rm -rf fonts

  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  mkdir ~/.vim/backup ~/.vim/swap ~/.vim/undo
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
  error "Error: Your OS is not Linux."
  exit
fi

# Change shell to ZSH
chsh -s $(which zsh) || error "Error: Cannot set zsh as default shell!"

# Clone the dotfiles repo
dir="$HOME/code/"
mkdir -p $dir
cd $dir
git clone git://github.com/siriniok/dotfiles.git
cd dotfiles

# Symlink the dotfiles
rake install

success "Please restart your PC!"

echo
echo -n $RED'-_-_-_-_-_-_-_'
echo    $RESET$BOLD',------,'$RESET
echo -n $YELLOW'_-_-_-_-_-_-_-'
echo    $RESET$BOLD'|   /\_/\\'$RESET
echo -n $GREEN'-_-_-_-_-_-_-'
echo    $RESET$BOLD'~|__( ^ .^)'$RESET
echo -n $CYAN'-_-_-_-_-_-_-_-'
echo    $RESET$BOLD'""  ""'$RESET
echo

exit 0
