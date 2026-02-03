# macOS supplies account management and the native login environment.
{
  config,
  flake,
  lib,
  ...
}:
{
  users.users = lib.genAttrs config.myusers (name: {
    home = "/Users/${name}";
  });
  system.primaryUser = flake.config.me.username;
}
