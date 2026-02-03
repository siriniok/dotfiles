# System and Home Manager constructors, with shared module context and exports.
{
  config,
  inputs,
  self,
  ...
}:
let
  # Shared context for this repository's NixOS, Darwin, and Home Manager modules.
  flake = { inherit self inputs config; };
in
{
  flake = {
    nixosModules.default = ../nixos;
    darwinModules.default = ../darwin;
    homeModules.default = ../home;

    nixosConfigurations.nixos-laptop = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit flake; };
      modules = [
        inputs.home-manager.nixosModules.home-manager
        ../../configurations/nixos/nixos-laptop
      ];
    };

    darwinConfigurations.darwin-laptop = inputs.nix-darwin.lib.darwinSystem {
      specialArgs = { inherit flake; };
      modules = [
        inputs.home-manager.darwinModules.home-manager
        ../../configurations/darwin/darwin-laptop.nix
      ];
    };
  };

  perSystem =
    { pkgs, ... }:
    {
      legacyPackages.homeConfigurations.default = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit flake; };
        modules = [ ../../configurations/home/default.nix ];
      };
    };
}
