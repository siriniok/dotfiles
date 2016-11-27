# Set personal aliases here.
# For a full list of active aliases, run `alias`.

# Enable aliases to be sudo’ed
#   http://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
alias sudo='sudo '


##############################################################################
# ZSH

alias zshs='source ~/.zshrc'
alias zshconfig='${EDITOR} ~/.zshrc'
alias ohmyzsh='${EDITOR} ~/.oh-my-zsh'
# List declared aliases, functions
alias listaliases="alias | sed 's/=.*//'"
# Show non _prefixed functions
alias listfunctions="declare -f | grep '^[a-z].* ()' | sed 's/{$//'"

##############################################################################


##############################################################################
# Shell Improvements

alias _='sudo'
alias fm='nautilus'
alias h='history'
alias hosts='${EDITOR} /etc/hosts'
alias quit='exit'

# Show $PATH in readable view
alias path='echo -e ${PATH//:/\\n}'
alias manpath='echo -e ${MANPATH//:/\\n}'

# Clipboard tools
alias xc='xclip -selection clipboard'
alias xp='xclip -selection clipboard -o'

##############################################################################


##############################################################################
# cd

alias c='cd'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cd.='cd $(readlink -f .)'

##############################################################################


##############################################################################
# tree

alias lss='ls -Gal'
alias lsp='ls -p'
alias tree='tree -A'
alias treed='tree -d'
alias tree1='tree -d -L 1'
alias tree2='tree -d -L 2'
alias ll1='tree --dirsfirst -ChFL 1'
alias ll2='tree --dirsfirst -ChFL 2'
alias ll3='tree --dirsfirst -ChFL 3'
alias ll4='tree --dirsfirst -ChFupDaL 1'
alias ll5='tree --dirsfirst -ChFupDaL 2'
alias ll6='tree --dirsfirst -ChFupDaL 3'

##############################################################################


##############################################################################
# Vim

alias v='vim'
alias vi='vim'
alias vic='${EDITOR} ~/.vimrc'

##############################################################################


##############################################################################
# Miscellaneous

# Display number of the current week and current date
alias week='date +%V'
alias currentdate='date "+%m/%d/%Y"'

# Display external and local IPs
alias ip='curl ipinfo.io/ip'
alias localips='ifconfig | sed -En "s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p"'

# Download web page with all assets
alias getpage='wget --no-clobber --page-requisites --html-extension --convert-links --no-host-directories'

# Download file with original filename
alias get='curl -O -L'

# Display weather in terminal
alias weather='curl -4 http://wttr.in'

# Internet Speedtest
alias stest='wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip'

# Cope ~/.ssh/id_rsa.pub to
alias myssh='cat ${SSH_KEY_PATH} | xc'

# Password generator
alias password='openssl rand -base64 ${1:-9} | xc ; echo "$(xp)"'

##############################################################################


##############################################################################
# Shortcuts for changing to specific directory

[ -d $DOTFILES ]              && alias dotfiles="cd ${DOTFILES}"
[ -d $CODE ]                  && alias wd="cd ${CODE}"

##############################################################################
