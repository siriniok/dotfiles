# Git hook definitions; nix develop generates the local hook configuration.
{ inputs, ... }:
{
  imports = [ (inputs.git-hooks + /flake-module.nix) ];
  perSystem =
    { config, pkgs, ... }:
    let
      zshFiles = "(\\.zsh$|(^|/)\\.z(shrc|shenv|login|logout|profile)$)";
    in
    {
      pre-commit.settings = {
        hooks = {
          zsh-syntax = {
            enable = true;
            name = "Zsh native syntax";
            files = zshFiles;
            types = [ "file" ];
            entry = toString (
              pkgs.writeShellScript "check-zsh-syntax" ''
                set -e
                for file in "$@"; do
                  ${pkgs.zsh}/bin/zsh -f -n -- "$file"
                done
              ''
            );
          };
          zsh-lint = {
            enable = true;
            name = "Zsh static analysis";
            files = zshFiles;
            types = [ "file" ];
            package = config.packages.zsh-lint;
            entry = "${config.packages.zsh-lint}/bin/zsh-lint";
          };
          nixfmt.enable = true;
          statix.enable = true;
          deadnix.enable = true;
          shellcheck = {
            enable = true;
            types = [ "shell" ];
            # Include non-executable .sh files, but exclude unsupported Zsh.
            excludes = [
              "\\.zsh$"
              "^modules/home/zsh/"
              "/\\.z(shrc|shenv|login|logout|profile)$"
            ];
          };
          gitleaks = {
            enable = true;
            args = [
              "dir"
              "--redact"
              "--no-banner"
              "."
            ];
          };
        };
      };
    };
}
