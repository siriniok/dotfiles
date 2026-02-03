# Home Manager substitutes @base64@, @openssl@, and @open@ with the selected
# executables, keeping command dependencies consistent across platforms.

# Encode a string or stdin as Base64, preserving whitespace exactly.
encode64() {
  (( $# <= 1 )) || { print -u2 'Usage: encode64 [STRING]'; return 2; }
  setopt localoptions pipefail
  if (( $# )); then
    print -rn -- "$1" | @base64@
  else
    @base64@
  fi
}

# Encode a file into FILE.txt; respect the shell's existing noclobber policy.
encodefile64() {
  (( $# == 1 )) || { print -u2 'Usage: encodefile64 FILE'; return 2; }
  @base64@ -- "$1" > "$1.txt"
}

# Decode a Base64 string or stdin with Nix's GNU coreutils on every platform.
decode64() {
  (( $# <= 1 )) || { print -u2 'Usage: decode64 [STRING]'; return 2; }
  setopt localoptions pipefail
  if (( $# )); then
    print -rn -- "$1" | @base64@ --decode
  else
    @base64@ --decode
  fi
}

# Native replacement for fancy-ctrl-z; registration belongs to interactive init.
_dotfiles_fancy_ctrl_z() {
  if [[ -z $BUFFER ]]; then
    BUFFER=fg
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}

# Copy stdin to the desktop clipboard, choosing the active display protocol.
xc() {
  (( $# == 0 )) || { print -u2 'Usage: COMMAND | xc (or xc < FILE)'; return 2; }
  if [[ $OSTYPE == darwin* ]]; then
    command /usr/bin/pbcopy
  elif [[ -n ${WAYLAND_DISPLAY:-} ]]; then
    command wl-copy
  elif [[ -n ${DISPLAY:-} ]]; then
    command xclip -selection clipboard
  else
    print -u2 'xc: no graphical clipboard available (no Wayland or X11 display)'
    return 1
  fi
}

# Paste clipboard contents without adding a newline to the copied data.
xp() {
  (( $# == 0 )) || { print -u2 'Usage: xp'; return 2; }
  if [[ $OSTYPE == darwin* ]]; then
    command /usr/bin/pbpaste
  elif [[ -n ${WAYLAND_DISPLAY:-} ]]; then
    command wl-paste --no-newline
  elif [[ -n ${DISPLAY:-} ]]; then
    command xclip -selection clipboard -o
  else
    print -u2 'xp: no graphical clipboard available (no Wayland or X11 display)'
    return 1
  fi
}

# Copy the Ed25519 public key to the clipboard.
myssh() {
  xc < "$HOME/.ssh/id_ed25519.pub"
}

# Open a file or directory in the platform's default desktop application.
fm() {
  (( $# <= 1 )) || { print -u2 'Usage: fm [PATH]'; return 2; }
  local target=${1:-.}
  @open@ "${target:A}"
}

# Generate, copy, and display a password; an optional argument sets random bytes.
password() {
  (( $# <= 1 )) || { print -u2 'Usage: password [BYTES]'; return 2; }
  local bytes=${1:-9}
  [[ $bytes == <-> ]] && (( bytes > 0 )) || { print -u2 'password: BYTES must be a positive integer'; return 2; }
  local generated
  generated=$(@openssl@ rand -base64 "$bytes") || return
  print -rn -- "$generated" | xc || return
  print -r -- "$generated"
}

# Print lines occurring more than once; read stdin when no file is supplied.
duplines() {
  (( $# <= 1 )) || { print -u2 'Usage: duplines [FILE]'; return 2; }
  setopt localoptions pipefail
  command sort -- "$@" | command uniq -d
}

# Print lines occurring exactly once, rather than deduplicating all lines.
uniqlines() {
  (( $# <= 1 )) || { print -u2 'Usage: uniqlines [FILE]'; return 2; }
  setopt localoptions pipefail
  command sort -- "$@" | command uniq -u
}

# Format JSON from a file, stdin, or HTTP(S); jq colours terminal output itself.
json() {
  (( $# <= 1 )) || { print -u2 'Usage: json [FILE|URL]'; return 2; }
  setopt localoptions pipefail
  local source=${1:--}
  case "$source" in
    http://*|https://*)
      command curl --fail --silent --show-error --location -- "$source" | command jq .
      ;;
    *) command jq . -- "$source" ;;
  esac
}

# Mirror a site and its page assets, rewriting links for offline browsing.
download_site() {
  (( $# == 1 )) || { print -u2 'Usage: download_site URL'; return 2; }
  command wget --limit-rate=200k --no-clobber --convert-links --random-wait \
    -r -p -E -e robots=off -U mozilla -- "$1"
}

# Combine gitignore templates: gi ruby node macos.
gi() {
  (( $# > 0 )) || { print -u2 'Usage: gi TEMPLATE [TEMPLATE ...]'; return 2; }
  command curl --fail --silent --show-error --location -- "https://www.gitignore.io/api/${(j:,:)@}"
}

# Create one directory (including parents) and enter it in the current shell.
mkd() {
  (( $# == 1 )) || { print -u2 'Usage: mkd DIRECTORY'; return 2; }
  command mkdir -p -- "$1" && builtin cd -- "$1"
}

# Colour a command's output while preserving command failures.
lol() {
  (( $# > 0 )) || { print -u2 'Usage: lol COMMAND [ARG ...]'; return 2; }
  setopt localoptions pipefail
  "$@" | command lolcat
}

# Time ten interactive shell startups using Zsh's portable built-in timer.
timezsh() {
  (( $# <= 1 )) || { print -u2 'Usage: timezsh [SHELL]'; return 2; }
  local shell_command=${1:-${SHELL:-zsh}}
  local attempt
  for attempt in {1..10}; do
    time "$shell_command" -i -c exit || return
  done
}
