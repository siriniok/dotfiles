# Run completely-clear-screen widget on C-l
bindkey '^L' completely-clear-screen

# Bind C-z to fg
_zsh_cli_fg() { fg; }
zle -N _zsh_cli_fg
bindkey '^Z' _zsh_cli_fg
