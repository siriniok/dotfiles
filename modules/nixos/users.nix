# Linux account creation and groups stay outside the shared Darwin policy.
{
  config,
  flake,
  lib,
  ...
}:
{
  # NixOS requires system integration for an account using Zsh. Follow Home
  # Manager's selection; completion and all interactive settings remain user-owned.
  programs.zsh = {
    enable = lib.any (name: config.home-manager.users.${name}.programs.zsh.enable) config.myusers;
    enableGlobalCompInit = false;
  };

  users.users = lib.genAttrs config.myusers (name: {
    isNormalUser = true;
    description = if name == flake.config.me.username then flake.config.me.fullname else name;
    # Only the public key enters the store. Additional users declare their own keys.
    openssh.authorizedKeys.keys = lib.optional (
      name == flake.config.me.username && flake.config.me.sshKey != ""
    ) flake.config.me.sshKey;
    extraGroups = [
      "networkmanager"
      "keyd"
      "scanner"
      "lp"
    ]
    ++ lib.optional (builtins.elem name config.userAccess.administrators) "wheel"
    ++ lib.optional (builtins.elem name config.userAccess.dockerUsers) "docker";
  });
  security.sudo.execWheelOnly = true;
}
