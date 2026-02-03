{
  config,
  flake,
  lib,
  pkgs,
  ...
}:
let
  work = "${config.home.homeDirectory}/Work";
  code = "${work}/code";
  checkout =
    if flake.config.me.dotfilesDirectory != null then
      flake.config.me.dotfilesDirectory
    else
      "${work}/dotfiles";
in
{
  # Extra user directories only. The host and Nix installer own system/profile
  # paths, including NixOS's privileged wrappers and Home Manager's profile.
  # Keep these shared entries in the same order on every platform.
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.bin"
    "$HOME/.cargo/bin" # Executables installed with cargo install.
    "$HOME/.docker/bin"
    "${checkout}/bin" # jaros and other checkout helpers, for all shells.
  ]
  ++ lib.optionals pkgs.stdenv.isDarwin [
    # Python's macOS user base; Linux user-installed scripts use .local/bin above.
    "$HOME/Library/Python/${pkgs.python3.pythonVersion}/bin"
  ];

  home.sessionVariables = {
    DOTFILES = checkout;
    WORK = work;
    CODE = code;
    C = code;
  };

  # Create the shared workspace without placing a managed file inside it.
  home.activation.createWorkDirectory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${lib.getExe' pkgs.coreutils "mkdir"} -p -- ${lib.escapeShellArg work}
  '';
}
