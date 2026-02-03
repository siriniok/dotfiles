# Host identity and policy; shared features live in modules/darwin.
{ flake, ... }:
{
  imports = [
    flake.inputs.self.darwinModules.default
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = flake.config.me.hostname;

  # Keep privileged daemon operations behind sudo, including for administrators.
  userAccess.nixTrustedUsers = [ ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
