{
  flake,
  lib,
  osConfig ? null,
  ...
}:
{
  imports = [
    flake.inputs.self.homeModules.default
  ];

  home.username = lib.mkDefault flake.config.me.username;

  # Standalone Home Manager has its own nixpkgs policy; integrated profiles use
  # their NixOS/Darwin host policy instead.
  nixpkgs = lib.mkIf (osConfig == null) {
    config.allowUnfreePredicate = import ../../lib/unfree-predicate.nix { inherit lib; };
    overlays = [ (import ../../lib/security-overlay.nix { inherit (flake) inputs; }) ];
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";
}
