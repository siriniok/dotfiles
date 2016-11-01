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
if [ `uname` == 'Linux' ]; then
  # Retrieve new lists of packages
  sudo apt-get update

  # Install latest git, zsh and ruby dependencies
  sudo apt-get install git zsh zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev libgdbm-dev libncurses5-dev automake libtool bison libffi-dev

  # Install latest RVM
  gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  curl -sSL https://get.rvm.io | bash -s stable
  source ~/.rvm/scripts/rvm

  # Install latest Ruby
  rvm install 2.3.1
  rvm use 2.3.1 --default
  ruby -v

  # Install bundler and rake
  gem install bundler
  gem install rake
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
git clone --recursive git://github.com/siriniok/dotfiles.git
cd dotfiles

# Symlink the dotfiles
rake install

success "Please restart your terminal!"

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
