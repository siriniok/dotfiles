# Show duplicate lines
duplines() {
  sort "$1" | uniq -d
}

# Show unique lines
uniqlines() {
  sort "$1" | uniq -u
}

# Pretty print JSON
json() {
  local url="$1"
  if [[ "http" == $url[0,4] ]]; then
    curl --silent $url | python -mjson.tool | pygmentize -O style=monokai -f console256 -g
  else
    cat $url | python -mjson.tool | pygmentize -O style=monokai -f console256 -g
  fi
}

# Donwload full copy of a site with wget
download_site() {
  wget --limit-rate=200k --no-clobber --convert-links --random-wait -r -p -E -e robots=off -U mozilla "$1"
}

# Download .gitignore for specific language
gi() {
  curl -L -s https://www.gitignore.io/api/$@
}

# Make directory (with parent directories as needed) and move to it
mkd() {
  mkdir -p -- "$@" && cd -- "$@"
}

# Just for lulz ;)
lol() {
  "$@" | lolcat
}


##############################################################################
# Visidata

# csv => txt
# csv => json
# xls => csv
# xslx => csv
# wikipedia table url => csv
csvtxt() { vd $1 -b -o $2 }

##############################################################################
