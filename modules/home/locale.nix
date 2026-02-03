{ lib, pkgs, ... }:
let
  locale = import ../../lib/locale.nix;
  timezone = import ../../lib/timezone.nix;
in
{
  home.language = {
    base = locale;
    monetary = locale;
  };

  # Also cover standalone profiles whose host timezone is managed outside Nix.
  home.sessionVariables.TZ = timezone;
  systemd.user.sessionVariables.TZ = lib.mkIf pkgs.stdenv.isLinux timezone;
}
