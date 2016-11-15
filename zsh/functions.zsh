# Show duplicate/unique lines
duplines() {
  sort "$1" | uniq -d
}

uniqlines() {
  sort "$1" | uniq -u
}

# Pretty print JSON
json() {
  local url="$1"
  if [[ "http" == $url[0,4] ]] ; then
    curl --silent $url | python -mjson.tool | pygmentize -O style=monokai -f console256 -g
  else
    cat $url | python -mjson.tool | pygmentize -O style=monokai -f console256 -g
  fi
}

function please() {
  sudo "$1"
}

function lol() {
  "$@" | lolcat
}

function download_site() {
  wget --limit-rate=200k --no-clobber --convert-links --random-wait -r -p -E -e robots=off -U mozilla "$1"
}

function gi() {
  curl http://www.gitignore.io/api/$@;
}

function mkd() {
  mkdir -p -- "$@" && cd -- "$@"
}

# find shorthand
function f() {
  find . -name "$1"
}
