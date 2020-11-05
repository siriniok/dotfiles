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

# Shutdown
alias shut='shutdown -h +45'
alias unshut='shutdown -c'

#############################################################################


##############################################################################
# cd

alias c='cd'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cd.='cd $(readlink -f .)'

# Directories

[ -d $DOTFILES ]              && alias dotfiles="cd ${DOTFILES}"
[ -d $CODE ]                  && alias wd="cd ${CODE}"
[ -d /work/code ]             && alias dw="cd /work/code"

##############################################################################


##############################################################################
# tree

alias els='exa'
alias elss='exa -Gal'
alias elhs='exa -lhS' # sort by file size
alias lhs='ls -lhS' # sort by file size
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
# Git

alias gclt='git clone --depth=1'
alias gitru='git clean -d'
alias gitrui='git clean -di'
alias gitrun='git clean -dn'
alias gnpd='git --no-pager diff'

##############################################################################


##############################################################################
# Editors

alias v=$EDITOR
alias vi=$EDITOR
alias vic='${EDITOR} ~/.vimrc'
alias emacs='emacs -nw'

# Prevent editors from being launched inside Neovim
if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
  alias nvim='echo "No nesting! Use nvr -o"'
  alias vim='echo "No nesting! Use nvr -o"'
fi

##############################################################################


##############################################################################
# Miscellaneous

# Fix this stupid snake
alias p2=python
alias python=python3

# Restark network services
alias rntwrk='sudo service network-manager restart'

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

# Increase the amount of inotify watches
alias incinotify='echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p'

# Run command every 30 seconds
alias w30s='watch -n 30'

# Run ngrok
alias ngrok3000='ngrok http -bind-tls=true 3000'
alias ngrok5000='ngrok http -bind-tls=true 5000'

# Liveshell
alias livestream='sh -c "$(wget -qO - liveshell.43z.one)"'

# QuickLook preview
alias ql='qlmanage -p'

# Prevent from sleeping for 1 hour
alias coffee='caffeinate -u -t 3600'
##############################################################################
