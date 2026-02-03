# Explicit composition: each imported module owns one family of flake outputs.
{
  imports = [
    ./identity.nix
    ./features.nix
    ./configurations.nix
    ./packages.nix
    ./activate-home.nix
    ./checks.nix
    ./hooks.nix
    ./devshell.nix
  ];
}
