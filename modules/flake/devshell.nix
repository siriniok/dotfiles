# Interactive development tools and checkout-local command discovery.
{
  perSystem = { config, pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      name = "nixos-config-shell";
      meta.description = "Dev environment for nixos-config";
      inputsFrom = [ config.pre-commit.devShell ];
      shellHook = ''
        # Resolve the writable checkout at shell entry, rather than a Nix store copy.
        if jaros_root="$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null)" \
          && [ -x "$jaros_root/bin/jaros" ]; then
          export PATH="$jaros_root/bin:$PATH"
        fi
        unset jaros_root
      '';
      packages = [
        config.packages.zsh-lint
      ]
      ++ (with pkgs; [
        janet
        jpm
        python3
        jq
        act
        actionlint
        nixfmt
        nixd
        nix-output-monitor
        statix
        deadnix
        shellcheck
        gitleaks
        zsh
      ]);
    };
  };
}
