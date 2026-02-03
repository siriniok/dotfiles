# NixOS composition. User programs and preferences belong to Home Manager.
{ flake, ... }:
{
  imports = [
    flake.inputs.sops-nix.nixosModules.sops
    ../system
    ./users.nix
    ./desktop.nix
    ./development.nix
    ./keyd.nix
    ./locale.nix
    ./networking.nix
    ./printing.nix
    ./security.nix
    ./services.nix
    ./waydroid.nix
  ];
}
