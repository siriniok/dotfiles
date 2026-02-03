{
  config,
  pkgs,
  lib,
  osConfig ? null,
  ...
}:
{
  # Follow the system's Nix selection on NixOS and nix-darwin; standalone
  # Home Manager uses the Nix package from the flake's nixpkgs input.
  nix.package = lib.mkDefault (if osConfig != null then osConfig.nix.package else pkgs.nix);
  home.packages = lib.optional (config.nix.package != null) config.nix.package;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
