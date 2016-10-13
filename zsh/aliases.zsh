# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.


# Zsh

alias zshs="source ~/.zshrc"

alias zshconfig="$EDITOR ~/.zshrc"
alias ohmyzsh="$EDITOR ~/.oh-my-zsh"


# Shortcuts

alias lc="lolcat"
alias fm="nautilus"
alias aptins="sudo apt-get install"
alias aptupd="sudo apt-get update"
alias _="sudo"
alias v="vim"


# List declared aliases, functions

alias listaliases="alias | sed 's/=.*//'"
alias listfunctions="declare -f | grep '^[a-z].* ()' | sed 's/{$//'" # show non _prefixed functions


# cd

alias c="cd"
alias to="cd"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias -- -="cd -"
alias cd.='cd $(readlink -f .)'

alias bd=". bd -s"

alias wd="cd ~/code"


# tree

alias lss="ls -Gal"
alias lsp="ls -p"
alias tree="tree -A"
alias treed="tree -d"
alias tree1="tree -d -L 1"
alias tree2="tree -d -L 2"
alias ll1="tree --dirsfirst -ChFL 1"
alias ll2="tree --dirsfirst -ChFL 2"
alias ll3="tree --dirsfirst -ChFL 3"
alias ll4="tree --dirsfirst -ChFupDaL 1"
alias ll5="tree --dirsfirst -ChFupDaL 2"
alias ll6="tree --dirsfirst -ChFupDaL 3"


# git

alias g="git"


# npm

alias ni="npm install"
alias nu="npm uninstall"


# Miscellaneous

alias quit="exit"
alias week="date +%V"
alias currentdate='date "+%m/%d/%Y"'
alias h="history"
alias hosts="$EDITOR /etc/hosts"
alias ip="curl ipinfo.io/ip"
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"
alias copy="xclip -sel clip"
alias my-ssh="xclip -sel clip < ~/.ssh/id_rsa.pub"
alias weather="curl -4 http://wttr.in"
alias stest="wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip"


# Directories

alias dotfiles="cd $DOTFILES"
