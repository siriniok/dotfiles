# Change shell to ZSH
chsh -s /bin/zsh

# Install latest rvm
sudo apt-get update
sudo apt-get install git zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev
sudo apt-get install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm

# Install latest ruby
rvm install 2.3.1
rvm use 2.3.1 --default
ruby -v

# Install bundler and rake
gem install bundler
gem install rake

# Clone the dotfiles repo
dir="$HOME/code/"
mkdir -p $dir
cd $dir
git clone --recursive git://github.com/siriniok/dotfiles.git
cd dotfiles

# Symlink the dotfiles
rake install
