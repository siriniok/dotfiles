# Local identity and hardware options for system and Home Manager configurations.
#
# Public names come from config.nix; machine-specific values come from local-config.
{ lib, inputs, ... }:
let
  userSubmodule = lib.types.submodule {
    options = {
      username = lib.mkOption {
        type = lib.types.str;
      };
      fullname = lib.mkOption {
        type = lib.types.str;
      };
      email = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
      hostname = lib.mkOption {
        type = lib.types.str;
        default = "nixos";
      };
      sshKey = lib.mkOption {
        type = lib.types.addCheck lib.types.str (
          value:
          value == ""
          ||
            builtins.match "(ssh-ed25519|sk-ssh-ed25519@openssh.com) [A-Za-z0-9+/]+={0,2}( [^\n\r]*)?" value
            != null
        );
        default = "";
        description = ''
          Ed25519 public key for the primary user's NixOS SSH login; empty leaves
          authorized keys unmanaged. Never put a private key here.
        '';
      };
      dotfilesDirectory = lib.mkOption {
        type = lib.types.nullOr (lib.types.addCheck lib.types.str (value: lib.hasPrefix "/" value));
        default = null;
        description = "Absolute checkout path on this machine; null uses ~/Work/dotfiles for each user.";
      };
    };
  };
in
{
  imports = [
    ../../config.nix
    (import inputs.local-config)
  ];
  options = {
    me = lib.mkOption {
      type = userSubmodule;
      description = "Machine-local identity; credentials must be loaded through runtime secrets.";
    };
    machine.nixosHardware = lib.mkOption {
      type = lib.types.deferredModule;
      default = import ../../configurations/nixos/nixos-laptop/hardware-configuration.nix;
      description = ''
        Generated NixOS hardware module embedded in config.local.nix. The default
        is a generic evaluation fixture, not this machine's filesystem layout.
        Embed the module itself: sibling imports beside a single-file flake input
        are not carried into the store automatically.
      '';
    };
  };
}
