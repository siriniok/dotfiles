{ pkgs, ... }:
{
  # The daemon is system-owned; the GTK client is a Home Manager application.
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    settings = {
      rpc-bind-address = "127.0.0.1";
      rpc-whitelist-enabled = true;
      rpc-host-whitelist-enabled = true;
      # Do not ask a router to expose the peer listener through UPnP/NAT-PMP.
      port-forwarding-enabled = false;
    };
  };
}
