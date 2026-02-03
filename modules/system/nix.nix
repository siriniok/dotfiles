{
  flake,
  pkgs,
  lib,
  ...
}:

{
  nixpkgs.config.allowUnfreePredicate = import ../../lib/unfree-predicate.nix { inherit lib; };
  nixpkgs.overlays = [ (import ../../lib/security-overlay.nix { inherit (flake) inputs; }) ];

  nix = {
    package = pkgs.nixVersions.latest;

    nixPath = [ "nixpkgs=${flake.inputs.nixpkgs}" ]; # Enables use of `nix-shell -p ...` etc
    registry = {
      nixpkgs.flake = flake.inputs.nixpkgs; # Make `nix shell` etc use pinned nixpkgs
    };

    settings = {
      # Do not let a project's flake silently change cache or daemon policy.
      accept-flake-config = false;
      require-sigs = true;
      sandbox = lib.mkIf pkgs.stdenv.isLinux true;
      max-jobs = "auto";
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # I don't have an Intel mac.
      extra-platforms = lib.mkIf pkgs.stdenv.isDarwin "aarch64-darwin x86_64-darwin";
      # Nullify the registry for purity.
      flake-registry = pkgs.writeText "empty-flake-registry.json" ''{"flakes":[],"version":2}'';
      max-call-depth = "1000000";
    };
  };
}
