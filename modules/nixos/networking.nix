{ pkgs, ... }:
{
  networking.networkmanager = {
    enable = true;
    plugins = [ pkgs.networkmanager-openvpn ];
  };
  services.tailscale.enable = true; # The service module also installs its CLI.
  programs.mtr.enable = true; # Privileged network diagnostics need system integration.

  environment.systemPackages = [ pkgs.cloudflare-warp ];
  systemd.packages = [ pkgs.cloudflare-warp ];
  systemd.targets.multi-user.wants = [ "warp-svc.service" ];
}
