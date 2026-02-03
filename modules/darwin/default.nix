# macOS system composition; user programs and dotfiles belong to Home Manager.
{
  imports = [
    ../system
    ./users.nix
    ./desktop.nix
    ./security.nix
  ];
}
