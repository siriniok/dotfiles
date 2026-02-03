{ lib, pkgs, ... }:
{
  # Nix packages to install to $HOME
  #
  # Search for packages here: https://search.nixos.org/packages
  home.packages = with pkgs; [
    janet
    age
    sops

    # Unix tools
    (callPackage ../../packages/trash-cli-sindresorhus { })
    certbot
    cloc
    cowsay
    dust
    eza # Maintained successor to exa.
    fd
    git-crypt
    gnumake
    htop
    httpie
    mc
    pstree
    ranger
    ripgrep # Better `grep`
    rlwrap
    sd
    shellcheck
    tldr
    tig
    tree

    # Network clients and diagnostics on Linux and macOS. Privileged services
    # belong to the host; installing these clients does not configure a VPN.
    openvpn
    tailscale
    mtr
    cloudflare-warp

    # Nix dev
    awscli2
    cachix
    gh
    google-cloud-sdk
    moreutils
    nil # Nix language server
    nix-info
    ngrok
    pgcli
    rainfrog
    terraform
    uv
  ];

  home.shellAliases = {
    j = "jaros";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Programs natively supported by home-manager.
  # Prefer native Home Manager modules when they configure the program too.
  programs = {
    zoxide.enable = true;
    fzf = {
      enable = true;
      # Include dotfiles in the picker and Ctrl+T, but not Git's internals.
      # Candidates must be filenames, rather than grep output with line numbers.
      defaultCommand = "${lib.getExe pkgs.fd} --type f --hidden --exclude .git";
      fileWidgetCommand = "${lib.getExe pkgs.fd} --type f --hidden --exclude .git";
    };
    less = {
      enable = true;
      options = {
        quit-if-one-screen = true;
        ignore-case = true;
        RAW-CONTROL-CHARS = true;
        quiet = true;
      };
    };
    btop.enable = true;
    # Better `cat`
    bat.enable = true;
    jq.enable = true;
  };

  home.sessionVariables.PAGER = "less";

}
