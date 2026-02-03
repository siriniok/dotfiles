{ lib, ... }:
let
  keyboard = import ../../../lib/gnome-keyboard.nix { inherit lib; };
in
{
  imports = [
    ./gnome.nix
    ./gdm.nix
  ];

  services.xserver = {
    enable = true;

    inherit (keyboard) xkb;
  };
}
