{ lib, pkgs, ... }:
lib.mkIf pkgs.stdenv.isLinux {
  home.packages =
    with pkgs;
    [
      traceroute
      killall
    ]
    ++ lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) (
      with pkgs;
      [
        transmission_4-gtk
        libreoffice
        hunspell
        hunspellDicts.uk_UA
        peazip
        unzip
        wl-clipboard
        xclip # Clipboard fallback for X11 sessions.
      ]
    )
    ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 (
      with pkgs;
      [
        wine64
        winetricks
      ]
    );
  xsession.enable = true;
}
