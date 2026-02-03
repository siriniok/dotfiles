{ pkgs, ... }:
{
  # Machine administration stays system-wide; user tools live in Home Manager.
  environment.systemPackages = [ pkgs.gparted ];
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
}
