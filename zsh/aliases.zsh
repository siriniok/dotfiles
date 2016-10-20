# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

# Enable aliases to be sudo’ed
#   http://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
alias sudo='sudo '

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
alias vi="vim"


# List declared aliases, functions

alias listaliases="alias | sed 's/=.*//'"
alias listfunctions="declare -f | grep '^[a-z].* ()' | sed 's/{$//'" # show non _prefixed functions


# cd

alias c="cd"
alias to="cd"
alias ..="cd .."
alias "cd.."="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias -- -="cd -"
alias cd.='cd $(readlink -f .)'


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
alias localips='ifconfig | sed -En "s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p"'
alias my-ssh="xclip -sel clip < ~/.ssh/id_rsa.pub"
alias weather="curl -4 http://wttr.in"
alias stest="wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip"

# Show $PATH in readable view
alias path='echo -e ${PATH//:/\\n}'

# Download web page with all assets
alias getpage='wget --no-clobber --page-requisites --html-extension --convert-links --no-host-directories'

# Download file with original filename
alias get="curl -O -L"

# Clipboard tools
if [ command -v xclip >/dev/null 2>&1 ]; then
  alias xcopy='xclip -selection clipboard'
  alias xpaste='xclip -selection clipboard -o'
fi

# Password generator
# Gemnerate random password, copies it into clipboard and outputs it to terminal
if [ command -v pbcopy >/dev/null 2>&1 ]; then
  alias password='openssl rand -base64 ${1:-9} | pbcopy ; echo "$(pbpaste)"'
fi
if [ command -v xcopy >/dev/null 2>&1 ]; then
  alias password='openssl rand -base64 ${1:-9} | xcopy ; echo "$(xpaste)"'
fi


# Folders Shortcuts
[ -d $DOTFILES ]              && alias dotfiles="cd $DOTFILES"
[ -d ~/code ]                 && alias dl='cd ~/code'
