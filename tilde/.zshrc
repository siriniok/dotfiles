##############################################################################
#                           Base ZSH configuration                           #
##############################################################################

DEFAULT_USER=$(whoami)

# Path to root of oh-my-zsh directory
export ZSH=$HOME/.oh-my-zsh

# Path to root of the development directory
export CODE=~/code

# Path to root of dotfiles directory
export DOTFILES=$CODE/dotfiles

# Set name of the theme to load. Look in ~/.oh-my-zsh/themes/
ZSH_THEME='agnoster'

##############################################################################
# Update Settings

# Disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE='true'

# Change how often to auto-update (in days)
export UPDATE_ZSH_DAYS=2

##############################################################################

##############################################################################
# Completion Settings

# Use case-sensitive completion
CASE_SENSITIVE='false'

# Enable command auto-correction
ENABLE_CORRECTION='true'

# Display red dots whilst waiting for completion
COMPLETION_WAITING_DOTS='true'

# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

##############################################################################

##############################################################################
# Miscellaneous

# Disable auto-setting terminal title
DISABLE_AUTO_TITLE='true'

# Allow comments even in interactive shells
setopt INTERACTIVE_COMMENTS

# This will add a 10 second wait before you can confirm a wildcard deletion
setopt RM_STAR_WAIT

# Instead of overwriting the history file, it appends lines
setopt APPEND_HISTORY

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
