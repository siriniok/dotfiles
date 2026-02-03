{ config, flake, ... }:
{
  imports = [ flake.inputs.sops-nix.homeManagerModules.sops ];
  sops.age = {
    keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    generateKey = true;
  };
}
