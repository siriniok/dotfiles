# Editor
# Preferred editor for local and remote sessions
if [[ -n "${SSH_CONNECTION}" ]]; then
  # remote
  if [ command -v vim >/dev/null 2>&1 ]; then
    export EDITOR='vim'
    export VISUAL='vim'
  else
    export EDITOR='vi'
    export VISUAL='vi'
  fi
else
  # local
  if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
    # Prevent editors from being launched inside Neovim
    export EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
    export VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
  else
    export EDITOR='nvim'
    export VISUAL='nvim'
  fi
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

# Vim
export VIMCONFIG=~/.vim
export VIMDATA=~/.vim

# Neovim
export NVIMCONFIG=~/.config/nvim
export NVIMDATA=~~/.local/share/nvim

# FZF
export FZF_DEFAULT_COMMAND="rg . --column --line-number --no-heading --color=auto --smart-case --hidden -g '!.git/'"
export FZF_CTRL_T_COMMAND="rg --files . --hidden -g '!.git/'"

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
_extend_path /usr/local/sbin $HOME/.bin $HOME/.cargo/bin $DOTFILES/bin $HOME/.docker/bin $HOME/.local/bin

# Add custom bin to $MANPATH
_extend_man_path /usr/local/man

PATH=$(_clear_path $PATH)
MANPATH=$(_clear_path $MANPATH)
