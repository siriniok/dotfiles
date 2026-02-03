# Policy shared by NixOS and nix-darwin, independent of either platform's services.
{
  imports = [
    ./users.nix
    ./nix.nix
    ./home-manager.nix
  ];

  time.timeZone = import ../../lib/timezone.nix;
}
