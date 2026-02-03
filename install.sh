#!/usr/bin/env bash
# Bootstrap from GitHub or activate a local checkout using its locked Nix inputs.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash install.sh [OPTIONS]
       bash downloaded-install.sh --ref REVIEWED_COMMIT [OPTIONS]

--directory PATH  Checkout destination (default: local configuration, then ~/Work/dotfiles)
--config PATH     Local Nix configuration to read and copy into a new checkout
--ref REF         Git revision to fetch for a new checkout (tag, branch, or commit)
--clone-only      Prepare the checkout without building or activating
--mode MODE       auto|home|nixos|darwin (default: auto)
--dry-run         Print commands without downloading, building, or activating

Cloning requires Git. Activation requires Nix and an edited config.local.nix.
auto selects NixOS on NixOS, nix-darwin on macOS, and Home Manager elsewhere.
Run as your login user; system activation requests sudo when needed.
EOF
}

fail() { printf 'install: %s\n' "$*" >&2; exit 1; }
is_checkout() { [[ -f $1/flake.nix && -f $1/flake.lock && -f $1/bin/jaros ]]; }
is_empty_directory() {
  [[ -d $1 && ! -L $1 ]] || return 1
  local entries
  entries=$(ls -A -- "$1") || return 1
  [[ -z $entries ]]
}
mode=auto
dry_run=false
clone_only=false
directory=
local_config=
revision=
print_command() { printf '  '; printf '%q ' "$@"; printf '\n'; }
while (($#)); do
  case "$1" in
    --mode)
      (($# >= 2)) || fail '--mode requires a value'
      mode=$2
      shift 2
      ;;
    --directory|--ref|--config)
      (($# >= 2)) && [[ -n $2 ]] || fail "$1 requires a value"
      case "$1" in
        --directory) directory=$2 ;;
        --config) local_config=$2 ;;
        --ref) revision=$2 ;;
      esac
      shift 2
      ;;
    --clone-only) clone_only=true; shift ;;
    --dry-run) dry_run=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *) fail "Unknown argument: $1 (see --help)" ;;
  esac
done
case "$mode" in auto|home|nixos|darwin) ;; *) fail "Unknown mode: $mode" ;; esac
[[ $revision != -* ]] || fail '--ref must not start with a dash'

# BASH_SOURCE may be empty when piped into bash; a downloaded file may be in /tmp.
source_directory=
if [[ -n ${BASH_SOURCE[0]:-} ]]; then
  source_directory=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
fi
# A piped installer can read config.local.nix from the current directory;
# a checkout-local installer prefers its own machine configuration.
if [[ -z $local_config ]]; then
  if [[ -n $source_directory && -f $source_directory/config.local.nix ]]; then
    local_config=$source_directory/config.local.nix
  elif [[ -f $PWD/config.local.nix ]]; then
    local_config=$PWD/config.local.nix
  fi
fi
configured_directory=
if [[ -n $local_config ]]; then
  [[ -f $local_config ]] || fail "Local configuration not found: $local_config"
  local_config=$(cd -- "$(dirname -- "$local_config")" && printf '%s/%s' "$PWD" "$(basename -- "$local_config")")
  command -v nix >/dev/null || fail 'Install Nix to read the local checkout directory'
  configured_directory=$(DOTFILES_INSTALL_CONFIG="$local_config" nix --extra-experimental-features nix-command eval --impure --raw --expr '
    let
      config = import (builtins.toPath (builtins.getEnv "DOTFILES_INSTALL_CONFIG"));
      directory = config.me.dotfilesDirectory or null;
    in
      if directory == null then ""
      else if builtins.isString directory && builtins.substring 0 1 directory == "/" then directory
      else throw "me.dotfilesDirectory must be an absolute path string"
  ')
fi
if [[ -n $directory && -n $configured_directory && $directory != "$configured_directory" ]]; then
  fail '--directory conflicts with me.dotfilesDirectory in the local configuration'
fi
if [[ -n $directory ]]; then root=$directory
elif [[ -n $configured_directory ]]; then root=$configured_directory
elif [[ -n $source_directory ]] && is_checkout "$source_directory"; then
  root=$source_directory
else root=$HOME/Work/dotfiles
fi
[[ $root == /* ]] || root=$PWD/$root

if ! "$dry_run"; then
  [[ $EUID != 0 ]] || fail 'Run as your login user, without sudo'
fi
if is_checkout "$root"; then
  [[ -z $revision ]] || fail '--ref is only supported for a new checkout; existing checkouts are left unchanged'
elif [[ -e $root || -L $root ]] && ! is_empty_directory "$root"; then
  fail "Destination exists but is not an empty directory or a dotfiles checkout: $root"
else
  printf 'Cloning dotfiles into %s\n' "$root"
  clone=(git clone)
  if [[ -n $revision ]]; then clone+=(--no-checkout)
  else clone+=(--branch nix)
  fi
  clone+=(-- https://github.com/siriniok/dotfiles.git "$root")
  print_command "${clone[@]}"
  if ! "$dry_run"; then
    command -v git >/dev/null || fail 'Install Git before cloning the dotfiles'
    "${clone[@]}"
  fi
  if [[ -n $revision ]]; then
    print_command git -C "$root" fetch --depth=1 -- origin "$revision"
    print_command git -C "$root" checkout --detach FETCH_HEAD
    if ! "$dry_run"; then
      git -C "$root" fetch --depth=1 -- origin "$revision"
      git -C "$root" checkout --detach FETCH_HEAD
    fi
  fi
  if ! "$dry_run"; then
    is_checkout "$root" || fail "Downloaded revision is not a Nix dotfiles checkout: $root"
  fi
fi
if [[ -d $root ]]; then root=$(cd -- "$root" && pwd -P); fi
# Git does not carry the ignored machine configuration into a fresh clone.
# Preserve existing destination configurations and never overwrite a different one.
if [[ -n $local_config && $local_config != "$root/config.local.nix" ]]; then
  [[ ! -L $root/config.local.nix ]] || fail "Destination config.local.nix is a symlink: $root"
  if [[ -e $root/config.local.nix ]]; then
    cmp -s "$local_config" "$root/config.local.nix" || fail "Destination has a different config.local.nix: $root"
  else
    print_command cp -- "$local_config" "$root/config.local.nix"
    if ! "$dry_run"; then
      (umask 077; cp -- "$local_config" "$root/config.local.nix")
    fi
  fi
fi
if "$clone_only"; then
  printf 'Next: review config.nix, config.local.nix (create if missing), and the host settings, then run:\n'
  print_command bash "$root/install.sh" --mode "$mode" --dry-run
  print_command bash "$root/install.sh" --mode "$mode"
  exit 0
fi
if [[ -d $root ]]; then
  root=$(cd -- "$root" && pwd -P)
  cd "$root"
fi
platform=$(uname -s)
case "$platform" in Linux|Darwin) ;; *) fail "Unsupported platform: $platform" ;; esac
if [[ $mode == auto ]]; then
  if [[ $platform == Darwin ]]; then mode=darwin
  elif [[ -e /etc/NIXOS ]]; then mode=nixos
  else mode=home
  fi
fi
[[ $mode != darwin || $platform == Darwin ]] || fail 'Darwin mode requires macOS'
[[ $mode != nixos || -e /etc/NIXOS ]] || fail 'NixOS mode requires NixOS'

if ! "$dry_run"; then
  command -v nix >/dev/null || fail 'Install Nix first: https://nixos.org/download/'
  [[ -f $root/config.local.nix ]] || fail "Create $root/config.local.nix using the README example first, then rerun bash $root/install.sh"
fi

# Keep flakes available on a fresh installation without editing global nix.conf.
nix_command=(nix --extra-experimental-features 'nix-command flakes')
local_input=(--no-write-lock-file --override-input local-config "path:$root/config.local.nix")
printf 'Installing from %s (%s)\n' "$root" "$mode"
case "$mode" in
  home)
    build=("${nix_command[@]}" build "${local_input[@]}" --no-link --print-out-paths
      "$root#homeConfigurations.default.activationPackage")
    print_command "${build[@]}"
    output='<build-output>'
    if ! "$dry_run"; then output=$("${build[@]}"); fi
    command=("$output/activate")
    print_command "${command[@]}"
    "$dry_run" || "${command[@]}"
    ;;
  nixos|darwin)
    if [[ $mode == nixos ]]; then
      target="$root#nixosConfigurations.nixos-laptop.config.system.build.nixos-rebuild"
      build=("${nix_command[@]}" build "${local_input[@]}")
      rebuild=nixos-rebuild
      profile=nixos-laptop
    else
      # Resolve nix-darwin through flake.lock, including before it is installed.
      target=nix-darwin#darwin-rebuild
      build=("${nix_command[@]}" build --no-write-lock-file --inputs-from "$root")
      rebuild=darwin-rebuild
      profile=darwin-laptop
    fi
    build+=(--no-link --print-out-paths "$target")
    print_command "${build[@]}"
    output='<build-output>'
    if ! "$dry_run"; then output=$("${build[@]}"); fi
    command=("$output/bin/$rebuild" switch --flake "$root#$profile" "${local_input[@]}")
    if [[ $mode == nixos ]]; then command+=(--sudo)
    else command=(sudo "${command[@]}")
    fi
    print_command "${command[@]}"
    "$dry_run" || "${command[@]}"
    ;;
esac
if "$dry_run"; then printf 'Preview complete; no changes made.\n'
else printf 'Done. Start a new login shell after activation.\n'
fi
