# Editor
# Preferred editor for local and remote sessions
if [[ -n "$SSH_CONNECTION" ]]; then
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

# Some options for our Zsh history. These will set our history to allow
# a ton more entires, ignore duplicate commands, and ignore some of the
# commands we don’t need a history of.

export HISTSIZE=10000;
export HISTFILESIZE=$HISTSIZE;
export SAVEHIST=$HISTSIZE;
export HISTCONTROL=ignoredups;
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help";

# Colors

export CLICOLOR=1
export LSCOLORS=gxfxcxdxbxegedabagacad
# export LSCOLORS="exfxcxdxbxegedabagacad"
# export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD

# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# your project folder
export PROJECTS=~/code

# Add custom bin to $PATH
[ -d /usr/local/heroku/bin ]      && _extend_path /usr/local/heroku/bin
[ -d $HOME ]                      && _extend_path $HOME/.bin
[ -d $HOME/.rvm/bin ]             && _extend_path $HOME/.rvm/bin
[ -d $HOME/.local/bin ]           && _extend_path $HOME/.local/bin
[ -d $HOME/.dotfiles/bin ]        && _extend_path $HOME/.dotfiles/bin

# Add custom bin to $MANPATH
MANPATH=${MANPATH}:/usr/local/man
MANPATH=${MANPATH}:/usr/local/mysql/man
MANPATH=${MANPATH}:/usr/local/git/man

export MANPATH=${MANPATH}

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="~/.ssh/dsa_id"
