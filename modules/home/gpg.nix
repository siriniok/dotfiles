{ lib, pkgs, ... }:
{
  programs.gpg.enable = true;
  # Home Manager owns the Linux user agent. macOS keeps its native SSH agent.
  services.gpg-agent = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
}
