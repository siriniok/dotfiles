# Share physical keyboard preferences across NixOS and standalone Linux profiles.
{
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.isLinux {
    xdg.configFile = {
      "keyd/default.conf".source = ./default.conf;
      "keyd/libinput.quirks".source = ./libinput.quirks;
    };
    # System provisioning is explicit; Home Manager never runs sudo on activation.
    home.packages = lib.optionals (osConfig == null) [
      pkgs.keyd
      (pkgs.callPackage ../../../packages/keyd-setup { })
    ];
  };
}
