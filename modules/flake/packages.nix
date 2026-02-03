# Local packages, package metadata, and the formatter used by nix fmt.
{ self, ... }:
{
  perSystem =
    {
      lib,
      pkgs,
      system,
      ...
    }:
    {
      packages = {
        zsh-lint = pkgs.callPackage ../../packages/zsh-lint { };
        trash-cli-sindresorhus = pkgs.callPackage ../../packages/trash-cli-sindresorhus { };
      }
      // lib.optionalAttrs (pkgs.stdenv.isDarwin || system == "x86_64-linux") {
        kueri = pkgs.callPackage ../../packages/kueri { };
      }
      // lib.optionalAttrs pkgs.stdenv.isLinux {
        keyd-setup = pkgs.callPackage ../../packages/keyd-setup { };
      };
      legacyPackages.packageInventory = import ../../lib/package-inventory.nix {
        inherit self system;
        inherit (pkgs) lib;
      };
      formatter = pkgs.nixfmt-tree;
    };
}
