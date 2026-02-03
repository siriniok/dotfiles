#!/usr/bin/env zsh
# Standalone script template; functions can also be sourced without running main.
# Inspired by https://github.com/bradp/dotfiles/blob/master/bin/bash_boilerblate

# Log to stderr so stdout remains available for script results. Only the label
# gets color, and message text is always literal (no escape/prompt expansion).
_log() {
  emulate -L zsh
  local level=$1
  shift
  local color='' reset=''
  local timestamp=${(%):-%D{%Y-%m-%dT%H:%M:%S%z}}
  if [[ -t 2 && -z ${NO_COLOR+x} && ${TERM:-dumb} != dumb ]]; then
    case $level in
      INFO) color=$'\e[32m' ;;
      WARN) color=$'\e[33m' ;;
      ERROR) color=$'\e[31m' ;;
    esac
    reset=$'\e[0m'
  fi
  printf '%s[%s]%s %s %s\n' "$color" "$level" "$reset" "$timestamp" "$*" >&2
}

info() { _log INFO "$@"; }
warn() { _log WARN "$@"; }
error() { _log ERROR "${ZSH_ARGZERO:t}: ${*:-Unknown error}"; }

# Terminate with a nonzero exit code. Invalid codes, including zero, become 1.
fail() {
  emulate -L zsh
  local exit_code=1 candidate=${2:-}
  if [[ $candidate =~ '^[1-9][0-9]{0,2}$' ]] && (( candidate <= 255 )); then
    exit_code=$candidate
  fi
  error "${1:-Unknown error}"
  exit "$exit_code"
}

# ask 'Continue?' [Y|N]: 0 = yes, 1 = no, 2 = EOF or invalid default.
# A default applies only to an empty answer, never to EOF. Use `if ask ...` so
# a negative answer can be handled without terminating a caller using ERR_EXIT.
ask() {
  emulate -L zsh
  local question=${1:-Continue?} default=${2:-} answer tail
  default=${(U)default}
  case $default in
    Y) tail='Y/n' ;;
    N) tail='y/N' ;;
    '') tail='y/n' ;;
    *) error 'ask: default must be Y or N'; return 2 ;;
  esac
  while true; do
    printf '%s [%s] ' "$question" "$tail" >&2
    if ! IFS= read -r answer; then
      printf '\n' >&2
      return 2
    fi
    [[ -n $answer ]] || answer=$default
    case ${(L)answer} in
      y|yes) return 0 ;;
      n|no) return 1 ;;
      *) printf 'Please answer yes or no.\n' >&2 ;;
    esac
  done
}

usage() {
  emulate -L zsh
  local script_name=${ZSH_ARGZERO:t}
  cat <<HELP
Usage: $script_name [OPTIONS] [--] [ARGUMENTS...]

Options:
  -h, --help                  Show this help and exit successfully
  -ex1, --example-one VALUE    Example option requiring a nonempty value
  --example-one=VALUE         Also accepts values beginning with a dash
  -ex2, --example-two          Example boolean flag
  --                          Treat remaining arguments as positional values

Examples:
  $script_name --example-one 'value with spaces' --example-two
  $script_name -- --a-literal-argument
HELP
}

main() {
  # Keep options local, including when this template is sourced by another script.
  emulate -L zsh
  setopt NO_UNSET PIPE_FAIL
  local example_one='' argument
  local -i example_two=0
  local -a positional=()

  if (( $# == 0 )); then
    usage
    return 0
  fi
  while (( $# )); do
    case $1 in
      -h|--help) usage; return 0 ;;
      -ex1|--example-one)
        if (( $# < 2 )) || [[ -z $2 || $2 == -* ]]; then
          error "$1 requires a value (use --example-one=VALUE for a leading dash)"
          return 2
        fi
        example_one=$2
        shift 2
        ;;
      --example-one=*)
        example_one=${1#*=}
        if [[ -z $example_one ]]; then
          error '--example-one requires a nonempty value'
          return 2
        fi
        shift
        ;;
      -ex2|--example-two) example_two=1; shift ;;
      --) shift; positional+=("$@"); break ;;
      -*) error "Unknown option: $1"; usage >&2; return 2 ;;
      *) positional+=("$1"); shift ;;
    esac
  done

  # Replace this demonstration with script-specific work. Check fallible commands
  # explicitly; avoid relying on ERR_EXIT's context-dependent behavior in Zsh.
  [[ -z $example_one ]] || info "Example one: $example_one"
  (( ! example_two )) || info 'Example two enabled'
  for argument in "${positional[@]}"; do
    printf '%s\n' "$argument"
  done
  return 0
}

if [[ $ZSH_EVAL_CONTEXT == toplevel ]]; then
  main "$@"
fi
