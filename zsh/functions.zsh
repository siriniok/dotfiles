# Show duplicate/unique lines
# Source: https://github.com/ain/.dotfiles/commit/967a2e65a44708449b6e93f87daa2721929cb87a

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

# Extract many types of compress files
# Source: http://nparikh.org/notes/zshrc.txt

extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)  tar -jxvf "$1"                        ;;
            *.tar.gz)   tar -zxvf "$1"                        ;;
            *.bz2)      bunzip2 "$1"                          ;;
            *.dmg)      hdiutil mount "$1"                    ;;
            *.gz)       gunzip "$1"                           ;;
            *.tar)      tar -xvf "$1"                         ;;
            *.tbz2)     tar -jxvf "$1"                        ;;
            *.tgz)      tar -zxvf "$1"                        ;;
            *.zip)      unzip "$1"                            ;;
            *.ZIP)      unzip "$1"                            ;;
            *.pax)      cat "$1" | pax -r                     ;;
            *.pax.Z)    uncompress "$1" --stdout | pax -r     ;;
            *.Z)        uncompress "$1"                       ;;
            *)          echo "'$1' cannot be extracted/mounted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file to extract"
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

function gi()  {
    curl http://www.gitignore.io/api/$@;
}

function mkd()  {
    mkdir -p -- "$@" && cd -- "$@"
}

# find shorthand
function f()  {
    find . -name "$1"
}
