{
  lib,
  flake,
  pkgs,
  osConfig ? null,
  ...
}:
let
  apps = flake.config.features.apps;
  kueri = pkgs.callPackage ../../packages/kueri { };
  # NixOS owns privileged wrappers; nix-darwin installs the native application
  # and CLI in the locations required for desktop integration.
  system1Password = osConfig != null && (osConfig.programs._1password-gui.enable or false);
  system1PasswordCli = osConfig != null && (osConfig.programs._1password.enable or false);
in
{
  home.packages = [
    pkgs.localsend
    pkgs.inkscape
    pkgs.zotero
    pkgs.beekeeper-studio
    pkgs.postman
    (if pkgs.stdenv.isDarwin then pkgs.firefox-bin else pkgs.firefox)
  ]
  ++ lib.optional (!system1Password) pkgs._1password-gui
  ++ lib.optional (!system1PasswordCli) pkgs._1password-cli
  ++ lib.optional apps.gitbutler.enable pkgs.gitbutler
  # These vendors do not ship ARM Linux desktop packages in the locked nixpkgs.
  ++ lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) (
    [
      pkgs.google-chrome
      pkgs.spotify
      pkgs.signal-desktop
      kueri # Upstream ships x86_64 Linux and both macOS architectures.
    ]
    ++ lib.optional apps.microsoftEdge.enable pkgs.microsoft-edge
    ++ lib.optional apps.androidStudio.enable pkgs.android-studio
  )
  ++ lib.optionals pkgs.stdenv.isLinux [
    pkgs.gimp
    pkgs.vlc
    pkgs.figma-linux # Community-maintained client; official desktop app is macOS/Windows only.
  ];

  # Google does not provide Drive for desktop on Linux. Expose its supported
  # web interface in the launcher without installing a third-party sync service.
  xdg.desktopEntries.google-drive = lib.mkIf pkgs.stdenv.isLinux {
    name = "Google Drive";
    comment = "Google Drive on the web";
    exec = "${lib.getExe' pkgs.xdg-utils "xdg-open"} https://drive.google.com";
    icon = "folder-remote";
    categories = [ "Network" ];
    terminal = false;
  };

  # VS Code and its extensions have a single owner in vscode.nix.
}
