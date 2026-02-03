{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Integrated profiles take their directory from the system account; standalone
  # profiles use this platform default and can override it explicitly.
  home.homeDirectory = lib.mkDefault (
    if pkgs.stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}"
  );
}
