# User development tools are available in integrated and standalone profiles.
{
  lib,
  pkgs,
  ...
}:
{
  home.packages =
    lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) (
      with pkgs;
      [
        cmake
        tree-sitter
        bottom
        gdu
      ]
    )
    ++ lib.optionals pkgs.stdenv.isLinux [ pkgs.gdb ];
  # Git, ripgrep, Python, and the C toolchain already have Home Manager owners.
}
