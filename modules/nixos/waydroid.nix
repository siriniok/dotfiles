{
  config,
  flake,
  pkgs,
  ...
}:
let
  homeDirectory = config.users.users.${flake.config.me.username}.home;
in
{
  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };
  # A mount unit can resolve the account's home after filesystem options are
  # collected; using that value as a fileSystems attribute name causes recursion.
  systemd.mounts = [
    {
      what = "${homeDirectory}/Waydroid";
      where = "${homeDirectory}/.local/share/waydroid/data/media/0/Linux";
      type = "none";
      options = "bind";
      wantedBy = [ "multi-user.target" ];
      unitConfig.RequiresMountsFor = homeDirectory;
    }
  ];
}
