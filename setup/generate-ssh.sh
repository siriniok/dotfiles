#!/usr/bin/env bash

# Generates new SSH keys and adds them to the ssh-agent

if [ $(uname) = 'Linux' ]; then
  COPY_TOOL=xclip
  SSH_ADD_OPTIONS=''
elif [ $(uname) = 'Darwin' ]; then
  COPY_TOOL=pbcopy
  SSH_ADD_OPTIONS='-K'
fi

# Reporters for bash scripts
e='\033'
RESET="${e}[0m"
BOLD="${e}[1m"
CYAN="${e}[0;96m"
RED="${e}[0;91m"
YELLOW="${e}[0;93m"
GREEN="${e}[0;92m"

# Success reporter
info() {
  echo ; echo -e "${CYAN}${BOLD}${*}${RESET}" ; echo
}

# Error reporter
error() {
  echo ; echo -e "${RED}${BOLD}${*}${RESET}" ; echo
}

# Success reporter
success() {
  echo ; echo -e "${GREEN}${BOLD}${*}${RESET}" ; echo
}

# Final catpick
catpick() {
  cowsay "Done!"
}

add_ssh_keys() {
  ssh-keygen -t rsa -b 4096 -C "siriniok@gmail.com"
  eval "$(ssh-agent -s)"
  ssh-add $SSH_ADD_OPTIONS ~/.ssh/id_rsa
}

copy_ssh_keys() {
  $COPY_TOOL -sel clip < ~/.ssh/id_rsa.pub
}

info "Adding SSH keys"
add_ssh_keys
copy_ssh_keys
success "SSH keys were copied to the clipboard"

info "Run ssh -T git@github.com and ssh -T git@gitlab.com to test SSH connection"

