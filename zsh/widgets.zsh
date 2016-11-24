# ZLE widget for clearing screen
completely-clear-screen() {
  echo -n '\ec'
  zle reset-prompt
}

zle -N completely-clear-screen
