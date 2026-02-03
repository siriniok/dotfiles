{ pkgs, ... }:
{
  # Discover driverless network printers such as the Canon MF752Cdw.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.printing = {
    enable = true;
    # Update the daemon without replacing libcups in every desktop dependency.
    package = pkgs.cups-security;
    listenAddresses = [ "localhost:631" ];
    browsed.enable = true;
    browsing = false;
    defaultShared = false;
  };
  hardware.sane.enable = true;
  environment.systemPackages = [ pkgs.hplip ];
}
