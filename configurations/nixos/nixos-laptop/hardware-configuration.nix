# Generic filesystem layout for public evaluation and CI only.
# Supply the generated machine module through machine.nixosHardware in config.local.nix.
{
  system.preSwitchChecks.requireLocalHardware = ''
    echo 'Set machine.nixosHardware in config.local.nix before activating this NixOS profile.' >&2
    exit 1
  '';
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };
}
