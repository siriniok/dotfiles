# Loaded after .zshrc in login interactive and non-interactive shells

export CARGO_DIR=$HOME/.cargo/
[[ -s $CARGO_DIR/env ]] && source $CARGO_DIR/env
