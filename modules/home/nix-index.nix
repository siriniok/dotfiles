{
  config,
  flake,
  lib,
  pkgs,
  ...
}:
let
  databaseHashes = (import (flake.inputs.nix-index-database + /generated.nix)).hashes;
  hasPrebuiltDatabase = builtins.hasAttr pkgs.stdenv.hostPlatform.system databaseHashes;
  # Use the upstream handler and database, but always select modern CLI hints.
  # Remove this adaptation when upstream offers a format setting:
  # https://github.com/nix-community/nix-index/issues/191
  modernCommandNotFound = pkgs.runCommand "nix-index-modern-command-not-found.sh" { } ''
    substitute ${config.programs.nix-index.package}/etc/profile.d/command-not-found.sh "$out" \
      --replace-fail '[ -e "$HOME/.nix-profile/manifest.json" ]' 'true'
  '';
in
{
  imports = [
    # NOTE: The nix-index DB is slow to search, until
    # https://github.com/nix-community/nix-index-database/issues/130
    flake.inputs.nix-index-database.homeModules.nix-index
  ];

  # command-not-found handler to suggest nix way of installing stuff.
  programs.nix-index = {
    enable = true;
    # The pinned database no longer publishes Intel macOS indexes. Keep that
    # platform usable with a locally generated index instead of a missing hash.
    package = lib.mkIf (!hasPrebuiltDatabase) pkgs.nix-index;
    symlinkToCacheHome = lib.mkIf (!hasPrebuiltDatabase) false;
    # Source our adapted handler instead of Home Manager's default handler.
    enableZshIntegration = false;
  };
  programs.zsh.initContent = ''
    source ${modernCommandNotFound}
  '';
  programs.nix-index-database.comma.enable = hasPrebuiltDatabase;
  home.packages = lib.optional (!hasPrebuiltDatabase) pkgs.comma;

}
