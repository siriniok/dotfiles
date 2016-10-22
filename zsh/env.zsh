# Editor
# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='subl'
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

# Path & Manpath

PATH=${PATH}:/usr/local/bin
PATH=${PATH}:/usr/local/sbin
PATH=${PATH}:/usr/bin
PATH=${PATH}:/bin
PATH=${PATH}:/usr/sbin
PATH=${PATH}:/sbin
PATH=${PATH}:/usr/local/git/bin
# PATH=${PATH}:/opt
PATH=${PATH}:/usr/local/heroku/bin
PATH=${PATH}:$HOME/.rvm/bin
PATH=${PATH}:$HOME/.local/bin
PATH=${PATH}:$HOME/.dotfiles/bin

export PATH=${PATH}

MANPATH=${MANPATH}:/usr/local/man
MANPATH=${MANPATH}:/usr/local/mysql/man
MANPATH=${MANPATH}:/usr/local/git/man

export MANPATH=${MANPATH}

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="~/.ssh/dsa_id"

export PATH="$PATH:$HOME/.rvm/bin"
