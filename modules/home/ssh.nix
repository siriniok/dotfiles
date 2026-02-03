{ lib, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    # Apple's client supports UseKeychain and the native launchd agent.
    package = if pkgs.stdenv.isDarwin then null else pkgs.openssh;

    # Keep personal hosts outside the flake; first values win over defaults below.
    includes = [ "~/.ssh/config.local" ];
    settings."*" = {
      AddKeysToAgent = "yes";
      ForwardAgent = false;
      HashKnownHosts = true;
      # Private keys stay in the home directory, never in the Nix store.
      IdentityFile = [
        "~/.ssh/id_ed25519"
      ];
    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      UseKeychain = "yes";
    };
  };

  # Linux already uses the declaratively configured GPG agent for SSH.
  # macOS supplies its own agent; do not spawn another one from shell startup.
}
