# Shared feature switches and host compatibility settings across installation modes.
{ lib, ... }:
{
  options.features = {
    desktop.gnomeShellVersion = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "46"
          "47"
          "48"
          "49"
          "50"
        ]
      );
      default = null;
      description = ''
        Host GNOME Shell major version for pinned extensions on standalone Linux.
        Null follows Nixpkgs; use "46" for Ubuntu 24.04, for example.
        This selects compatible extensions without installing another GNOME Shell.
      '';
    };
    apps = {
      gitbutler.enable = lib.mkEnableOption "GitButler on supported platforms";
      microsoftEdge.enable = lib.mkEnableOption "Microsoft Edge on supported platforms";
      androidStudio.enable = lib.mkEnableOption "Android Studio (Nix on Linux, Homebrew on macOS)";
    };
    languages.haskell.enable = lib.mkEnableOption "the Haskell compiler, tools, and editor integrations";
  };
}
