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

# SSH
export SSH_KEY_PATH=~/.ssh/id_rsa.pub

# Pager settings
# Default pager
export PAGER='less'

export LESS="--quit-if-one-screen --ignore-case --RAW-CONTROL-CHARS --quiet --dumb"

# Path to your development directory

# Vim
export VIMCONFIG=~/.vim
export VIMDATA=~/.vim

# Neovim
export NVIMCONFIG=~/.config/nvim
export NVIMDATA=~~/.local/share/nvim

# FZF
export FZF_DEFAULT_COMMAND="rg . --column --line-number --no-heading --color=auto --smart-case --hidden -g '!.git/'"
export FZF_CTRL_T_COMMAND="rg --files . --hidden -g '!.git/'"
