# The pre-login greeter is system-owned; session preferences live in Home Manager.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  keyboard = import ../../../lib/gnome-keyboard.nix {
    inherit lib;
    xkb = config.services.xserver.xkb;
  };
in
{
  # GNOME 50 is Wayland-only; "gnome" is its native Wayland session. The old
  # gdm.wayland option was removed upstream and must not be reintroduced.
  services.displayManager.defaultSession = "gnome";
  services.displayManager.gdm = {
    enable = true;
    extraPackages = [ pkgs.yaru-theme ];
  };
  programs.dconf.profiles.gdm.databases = [
    {
      settings = lib.recursiveUpdate keyboard.settings {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          accent-color = "orange";
          gtk-theme = "Yaru-dark";
          icon-theme = "Yaru";
          cursor-theme = "Yaru";
          clock-format = "24h";
        };
      };
    }
  ];
}
