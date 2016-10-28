# Use this files instead of .zlogin for launching scripts on ZSH login.
# It will be reloaded on .zshrc sourcing.

TRAVIS="$HOME/.travis/travis.sh"
[ -s $TRAVIS ] && source $TRAVIS

RVM="$HOME/.rvm/scripts/rvm"
[[ -s $RVM ]] && source $RVM
