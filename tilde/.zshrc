#!/usr/bin/env zsh

##############################################################################
#                           Base ZSH configuration                           #
##############################################################################

DEFAULT_USER=$(whoami)

# Path to root of oh-my-zsh directory
export ZSH=$HOME/.oh-my-zsh

# Path to root of the development directory
export CODE=~/Work/code/

# Path to root of dotfiles directory
export DOTFILES=~/Work/.dotfiles

# Set name of the theme to load. Look in ~/.oh-my-zsh/themes/
ZSH_THEME='agnoster'

##############################################################################
# Update Settings

# Disable bi-weekly auto-update checks
DISABLE_AUTO_UPDATE=false

# Change how often to auto-update (in days)
export UPDATE_ZSH_DAYS=14

##############################################################################

##############################################################################
# Completion Settings

# Use case-sensitive completion
CASE_SENSITIVE='false'

# Display red dots whilst waiting for completion
COMPLETION_WAITING_DOTS='true'

# Pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pend

# Formatting and messages
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format "$fg[yellow]%B--- %d%b"
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format "$fg[red]No matches for:$reset_color %d"
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

##############################################################################

##############################################################################
# Miscellaneous

# Disable auto-setting terminal title
DISABLE_AUTO_TITLE='true'

# Allow comments even in interactive shells
setopt INTERACTIVE_COMMENTS

# This will add a 10 second wait before you can confirm a wildcard deletion
setopt RM_STAR_WAIT

# Share history between sessions
unsetopt INC_APPEND_HISTORY
unsetopt INC_APPEND_HISTORY_TIME
setopt SHARE_HISTORY

# Do not override files using `>`, but it's still possible using `>!`
set -o noclobber

# This will highlight the patterns you specify in a color of your choice
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_PATTERNS=('rm -rf *' 'fg=white,bold,bg=red')
ZSH_HIGHLIGHT_PATTERNS=('git push origin master' 'fg=white,bold,bg=red')

##############################################################################
# Load ZSH config files

for file in $DOTFILES/zsh/*; do
  source $file
done

##############################################################################

# Run OMZSH
source $ZSH/oh-my-zsh.sh

# Export dotfiles version
source $DOTFILES/version.zsh

# Load extra (private) settings
[ -f $HOME/.zshlocal ] && source $HOME/.zshlocal
[ -f $HOME/.secret ] && source $HOME/.secret

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
