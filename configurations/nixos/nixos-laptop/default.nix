# Host identity and policy; shared features live in modules/nixos.
{ flake, ... }:
{
  imports = [
    flake.inputs.self.nixosModules.default
    ./hardware.nix
    flake.config.machine.nixosHardware
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  # Keep the profile name stable while taking the hostname from local identity.
  networking.hostName = flake.config.me.hostname;

  # Newly managed users receive no administrator or daemon-trust privileges.
  userAccess = {
    administrators = [ flake.config.me.username ];
    dockerUsers = [ ]; # Rootless Docker needs no docker group membership.
    # Daemon trust bypasses the sudo boundary; ordinary builds do not need it.
    nixTrustedUsers = [ ];
  };

  # Compatibility baseline from the original installation, not the current release.
  system.stateVersion = "24.05";
}
