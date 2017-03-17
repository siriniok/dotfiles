



# Install APT packages.
packages=(
  build-essential
  cowsay
  git-core
  htop
  id3tool
  libssl-dev
  nmap
  silversearcher-ag
  sl
  telnet
  tree
)

packages=($(setdiff "${packages[*]}" "$(dpkg --get-selections | grep -v deinstall | awk '{print $1}')"))

if (( ${#packages[@]} > 0 )); then
  e_header "Installing APT packages: ${packages[*]}"
  for package in "${packages[@]}"; do
    sudo apt-get -qq install "$package"
  done
fi

# Install Git Extras
if [[ ! "$(type -P git-extras)" ]]; then
  e_header "Installing Git Extras"
  (
    cd $DOTFILES/vendor/git-extras &&
    sudo make install
  )
fi






















echo "Update Ubuntu"
sudo apt-get update
sudo apt-get upgrade
sudo apt-get update

echo "Installing Chrome..."
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo apt-get update
sudo apt-get install google-chrome-stable

echo "Installing Ubuntu Tweak..."
sudo add-apt-repository ppa:tualatrix/ppa
sudo apt-get update
sudo apt-get install ubuntu-tweak

echo "Installing Preload..."
sudo apt-get install preload

echo "Add SSH keys"
ssh-keygen -t rsa -b 4096 -C "siriniok@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

echo "Installing Git..."
sudo apt-get install git

echo "Git config"
git config --global user.name "Vladyslav Siriniok"
git config --global user.email siriniok@gmail.com

echo "Copying dotfiles from Bitbucket"
cd ~/code
git clone --git@bitbucket.org:siriniok/dotfiles.git dotfiles
cd ~/dotfiles
rake
cd ~

# Install wine1.6
sudo apt-get install -y wine1.6
winecfg

# Install Curl
sudo apt-get install curl

# Install Zsh & Oh My Zsh
echo "Installing Oh My ZSH..."
sudo apt-get install zsh
curl -L http://install.ohmyz.sh | sh

echo "Setting ZSH as shell..."
chsh -s $(which zsh)

# Apps
apps=(
 build-essential
 cowsay
 dconf-tools
 filezilla
 gimp
 gparted
 nodejs
 rake
 skype
 tree
 unetbootin
 vim
 vlc
 xclip
 tig
 tig wget
)

echo "Installing apps with Apt..."
sudo apt-get install -y ${apps[@]}

echo "Install Simple Screen Recorder"
sudo add-apt-repository ppa:maarten-baert/simplescreenrecorder
sudo apt-get update
sudo apt-get install simplescreenrecorder

echo "Install Grub Customizer"
sudo add-apt-repository ppa:danielrichter2007/grub-customizer
sudo apt-get update
sudo apt-get install grub-customizer

echo "Install Docker"
wget -qO- https://get.docker.com/ | sh
docker -v

echo "Install Google Drive Ocamlfuse"
sudo add-apt-repository ppa:alessandro-strada/ppa
sudo apt-get update
sudo apt-get install google-drive-ocamlfuse

echo "Install Cuttlefish"
sudo add-apt-repository ppa:noneed4anick/cuttlefish
sudo apt-get update
sudo apt-get install cuttlefish

echo "Install Caffeine"
sudo add-apt-repository ppa:caffeine-developers/ppa
sudo apt-get update
sudo apt-get install caffeine

echo "Install Zsh Syntax Highlighting"
cd ~/.oh-my-zsh/custom/plugins
git clone git://github.com/zsh-users/zsh-syntax-highlighting.git
cd ~
reload!

echo "remove Libre Office"
sudo apt-get remove --purge libreoffice*

echo "remove useless apps, scopes and lenses"
sudo apt-get autoremove unity-lens-music unity-lens-photos unity-lens-gwibber \
unity-lens-shopping unity-lens-video unity-scope-audacious unity-scope-zotero \
unity-scope-yelp unity-scope-video-remote unity-scope-tomboy unity-scope-texdoc \
unity-scope-openclipart unity-scope-musique unity-scope-musicstores \
unity-scope-clementine unity-scope-devhelp unity-scope-guayadeque \
unity-scope-gmusicbrowser unity-scope-gourmet unity-scope-manpages \
unity-scope-colourlovers

sudo apt-get autoremove brasero brasero-cdrkit brasero-common fontforge \
fontforge-common empathy empathy-common

sudo apt-get autoremove thunderbird amazon gedit brasero brasero-cdrkit \
brasero-common fontforge fontforge-common empathy empathy-common

sudo apt-get autoremove
sudo apt-get clean
sudo apt-get autoclean

# Display all startup applications
sudo sed -i 's/NoDisplay=true/NoDisplay=false/g' /etc/xdg/autostart/*.desktop
echo "Now you can edit your startup apps"

echo "Update Ubuntu"
sudo apt-get update
sudo apt-get upgrade
sudo apt-get update

echo "Done!"

pip install autoenv
