{
  description = "Vladyslav Siriniok's dotfiles";

  inputs = {
    # Safe shared defaults; local activation overrides this with an ignored file.
    local-config = {
      url = "path:./config.nix";
      flake = false;
    };
    # Core inputs (updated by `jaros update`).
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # Targeted Linux application/security updates; the host stays on its release.
    nixpkgs-security.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Software inputs
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    lazyvim.url = "github:pfassina/lazyvim-nix";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Devshell
    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.flake = false;
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      imports = [
        ./modules/flake
      ];
    };
}
