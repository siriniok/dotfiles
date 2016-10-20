export ZSH=$HOME/.oh-my-zsh
export DOTFILES=$HOME/.dotfiles

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="agnoster"
# eval `dircolors ~/.solarized/set_dark.sh`

DEFAULT_USER=$(whoami)

# Allow comments even in interactive shells (
setopt INTERACTIVE_COMMENTS

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=1

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# This will add a 10 second wait before you can confirm a wildcard deletion.
setopt RM_STAR_WAIT

# Instead of overwriting the history file, it appends lines. This helps if there are multiple zsh sessions, so that they don't just overwrite the history.
setopt APPEND_HISTORY

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# This will highlight the patterns you specify in a color of your choice.
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_PATTERNS=('rm -rf *' 'fg=white,bold,bg=red')
ZSH_HIGHLIGHT_PATTERNS=('git push origin master' 'fg=white,bold,bg=red')

# load zsh config files
for file in $DOTFILES/zsh/*
do
  source $file
done

# autoenv
source `which activate.sh`

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  bundler
  capistrano
  catimg
  catimg
  copyfile
  cp
  debian
  docker
  extract
  gem
  git
  git-extras
  github
  history
  lol
  node
  npm
  nvm
  nyan
  rails
  rake
  rake-fast
  ruby
  rvm
  sublime
  sudo
  tmux
  web-search
  z
  zsh-syntax-highlighting
  dircycle
  colorize
  # autoenv
  # last-working-dir
)

# User configuration
source $ZSH/oh-my-zsh.sh
# source $DOTFILES/version.zsh

test -f $DOTFILES/.secret && $DOTFILES/.secret

export NODE_PATH=$NODE_PATH:$HOME/.nvm/versions/node/v5.9.1/lib/node_modules

[ -f $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh
