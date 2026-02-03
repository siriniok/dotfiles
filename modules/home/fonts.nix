{ lib, pkgs, ... }:
let
  size = 11;
in
{
  home.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
  ];
  fonts.fontconfig = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    antialiasing = true;
    # Slight hinting keeps small text aligned without heavily reshaping glyphs.
    hinting = "slight";
    # Grayscale avoids depending on a display's RGB/BGR pixel arrangement.
    subpixelRendering = "none";
    defaultFonts = {
      sansSerif = [ "Adwaita Sans" ];
      monospace = [ "Adwaita Mono" ];
    };
  };

  # Use macOS's normal smoothing level, including with standalone Home Manager.
  targets.darwin.defaults = lib.mkIf pkgs.stdenv.isDarwin {
    NSGlobalDomain.AppleFontSmoothing = 2;
  };

  # Shared session defaults for NixOS and standalone Linux (including Ubuntu).
  # Keep GNOME's Adwaita families and provide them for non-NixOS hosts too.
  gtk = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    font = {
      name = "Adwaita Sans";
      inherit size;
      package = pkgs.adwaita-fonts;
    };
  };
  dconf.settings = lib.mkIf pkgs.stdenv.isLinux {
    "org/gnome/desktop/interface" = {
      font-name = "Adwaita Sans ${toString size}";
      document-font-name = "Adwaita Sans ${toString size}";
      monospace-font-name = "Adwaita Mono ${toString size}";
      font-antialiasing = "grayscale";
      font-hinting = "slight";
    };
    "org/gnome/desktop/wm/preferences".titlebar-font = "Adwaita Sans Bold ${toString size}";
  };
}
