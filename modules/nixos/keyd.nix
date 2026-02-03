{ config, pkgs, ... }:
{
  boot.kernelModules = [ "uinput" ];
  environment.systemPackages = [ pkgs.keyd ];
  systemd.packages = [ pkgs.keyd ];

  environment.etc."keyd/default.conf".source = ../home/keyd/default.conf;

  environment.etc."libinput/local-overrides.quirks".source = ../home/keyd/libinput.quirks;

  systemd.services.keyd = {
    description = "keyd keyboard remapping daemon";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    # Reload remappings on activation when the generated configuration changes.
    reloadTriggers = [ config.environment.etc."keyd/default.conf".source ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.keyd}/bin/keyd";
      ExecReload = "${pkgs.keyd}/bin/keyd reload";
      Restart = "on-failure";
      RestartSec = "1s";
    };
  };
}
