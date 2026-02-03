# Resolve tools once per Home Manager configuration and reuse the same derivations.
{
  config,
  flake,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.editorTools = lib.mkOption {
    type = lib.types.raw;
    internal = true;
    readOnly = true;
    description = "Resolved shared editor tools; owned by this module.";
  };

  config = {
    dotfiles.editorTools = import ../../lib/editor-tools.nix {
      inherit pkgs;
      jdk = config.programs.java.package;
      haskell = flake.config.features.languages.haskell.enable;
    };
    # GUI editors and terminals see the same tools on PATH.
    home.packages = config.dotfiles.editorTools.packages;
  };
}
