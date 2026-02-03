# Shared account selection and explicit privilege policy; platform modules create accounts.
{
  flake,
  lib,
  config,
  ...
}:
{
  options = {
    myusers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of usernames";
      defaultText = "The primary user selected by me.username";
      default = [ flake.config.me.username ];
    };
    userAccess = {
      administrators = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Managed users granted wheel membership on NixOS. macOS administrator groups are managed separately.";
      };
      dockerUsers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Managed users granted access to the rootful Docker daemon on NixOS (root-equivalent access).";
      };
      nixTrustedUsers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Managed users trusted by the Nix daemon in addition to root (root-equivalent access).";
      };
    };
  };

  config = {
    assertions =
      map
        (role: {
          assertion = builtins.all (name: builtins.elem name config.myusers) config.userAccess.${role};
          message = "userAccess.${role} must contain only usernames listed in myusers.";
        })
        [
          "administrators"
          "dockerUsers"
          "nixTrustedUsers"
        ];
    nix.settings.trusted-users = [ "root" ] ++ config.userAccess.nixTrustedUsers;
  };
}
