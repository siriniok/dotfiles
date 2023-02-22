# Loaded by all invokations, of ZSH keep as small as possible

##############################################################################
#                               PATH & MANPATH                               #
##############################################################################

# Extend $PATH without duplicates
_extend_path() {
  if ! $( echo "$PATH" | tr ":" "\n" | grep -qx "$1" ); then
    PATH="$PATH:${(j.:.)*}"
  fi
}

# Extend $MANPATH without duplicates
_extend_man_path() {
  if ! $( echo "$MANPATH" | tr ":" "\n" | grep -qx "$1" ); then
    MANPATH="$MANPATH:${(j.:.)*}"
  fi
}

# Remove existed duplicates and empty lines
_clear_path() {
  echo -n "$1" | awk -v RS=: -v ORS=: 'length($0) != 0 && !arr[$0]++'
}

# Add custom bin to $PATH
_extend_path /usr/local/sbin $HOME/.bin $HOME/.cargo/bin $DOTFILES/bin $HOME/.docker/bin $HOME/.local/bin $HOME/Library/Python/3.10/bin

# Add custom bin to $MANPATH
_extend_man_path /usr/local/man

PATH=$(_clear_path $PATH)
MANPATH=$(_clear_path $MANPATH)
