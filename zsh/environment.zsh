# Editor
# Preferred editor for local and remote sessions
if [[ -n "${SSH_CONNECTION}" ]]; then
  # on the server
  if [ command -v vim >/dev/null 2>&1 ]; then
    export EDITOR='vim'
  else
    export EDITOR='vi'
  fi
else
  # local
  export EDITOR='vim' # change to 'subl' if needed
fi

# History
export HISTSIZE=10000
export HISTFILESIZE=$HISTSIZE
export SAVEHIST=$HISTSIZE
export HISTCONTROL='ignoredups'
export HISTIGNORE='ls:cd:cd -:pwd:exit:date:* --help'

# Locale
export LC_ALL='en_US.UTF-8'
export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'

# SSH
export SSH_KEY_PATH=~/.ssh/id_rsa.pub

# Pager settings
# Default pager
export PAGER='less'

# less options
less_opts=(
  # Quit if entire file fits on first screen.
  --quit-if-one-screen
  # Ignore case in searches that do not contain uppercase.
  --ignore-case
  # Allow ANSI colour escapes, but no other escapes.
  --RAW-CONTROL-CHARS
  # Quiet the terminal bell. (when trying to scroll past the end of the buffer)
  --quiet
  # Do not complain when we are on a dumb terminal.
  --dumb
)
export LESS="${less_opts[*]}"


# Path to your development directory
export C=$CODE

##############################################################################
#                               PATH & MANPATH                               #
##############################################################################

# Extend $PATH without duplicates
_extend_path() {
  if ! $( echo "$PATH" | tr ":" "\n" | grep -qx "$1" ); then
    PATH="$1:$PATH"
  fi
}

# Extend $MANPATH without duplicates
_extend_man_path() {
  if ! $( echo "$MANPATH" | tr ":" "\n" | grep -qx "$1" ); then
    MANPATH="$1:$MANPATH"
  fi
}

# Remove existed duplicates and empty lines
_clear_path() {
  echo -n "$1" | awk -v RS=: -v ORS=: 'length($0) != 0 && !arr[$0]++'
}

# Add custom bin to $PATH
[ -d /usr/local/heroku/bin ]      && _extend_path /usr/local/heroku/bin
[ -d $HOME ]                      && _extend_path $HOME/.bin
[ -d $HOME/.rvm/bin ]             && _extend_path $HOME/.rvm/bin
[ -d $HOME/.local/bin ]           && _extend_path $HOME/.local/bin
[ -d $DOTFILES/bin ]              && _extend_path $DOTFILES/bin

# Add custom bin to $MANPATH
[ -d /usr/local/man ]             && _extend_man_path /usr/local/man
[ -d /usr/local/man ]             && _extend_man_path /usr/local/man

PATH=$(_clear_path $PATH)
MANPATH=$(_clear_path $MANPATH)
