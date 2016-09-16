# Change shell to ZSH
chsh -s /bin/zsh

# Clone dotfiles repo
dir="$HOME/code/"
mkdir -p $dir
cd $dir
git clone --recursive git://github.com/siriniok/dotfiles.git
cd dotfiles
