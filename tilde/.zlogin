export TRAVIS_DIR="$HOME/.travis"
[[ -s "$TRAVIS_DIR/travis.sh" ]] && source "$TRAVIS_DIR/travis.sh"

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

export RVM_DIR=$HOME/.rvm
[[ -s $RVM_DIR/scripts/rvm ]] && source $RVM_DIR/scripts/rvm

export CARGO_DIR=$HOME/.cargo/
[[ -s $CARGO_DIR/env ]] && source $CARGO_DIR/env
