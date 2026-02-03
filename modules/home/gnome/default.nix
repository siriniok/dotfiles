# GNOME session preferences belong to the user, including on Ubuntu.
{
  flake,
  lib,
  pkgs,
  ...
}:
let
  keyboard = import ../../../lib/gnome-keyboard.nix { inherit lib; };
  shellVersion = flake.config.features.desktop.gnomeShellVersion;
  extensionFor =
    name:
    let
      current = pkgs.gnomeExtensions.${name};
    in
    if shellVersion == null then
      current
    else
      pkgs."gnome${shellVersion}Extensions".${current.extensionUuid};
  extensions = map extensionFor [
    "cloudflare-warp-toggle"
    "clipboard-indicator"
    "appindicator"
    "desktop-icons-ng-ding"
    "tiling-assistant"
  ];
in
{
  imports = [ ./keybindings.nix ];
  config = lib.mkIf pkgs.stdenv.isLinux {
    # Ubuntu's GTK, icon and cursor theme, without forcing GTK_THEME on libadwaita apps.
    gtk = {
      theme = {
        name = "Yaru-dark";
        package = pkgs.yaru-theme;
      };
      iconTheme = {
        name = "Yaru";
        package = pkgs.yaru-theme;
      };
      # Let GTK4/libadwaita use the supported dark-mode and accent preferences.
      gtk4.theme = null;
    };
    home.pointerCursor = {
      name = "Yaru";
      package = pkgs.yaru-theme;
      size = 24;
      gtk.enable = true;
    };
    dconf = {
      enable = true;
      settings = lib.recursiveUpdate keyboard.settings {
        # Match the system locale for dates, numbers, currency, and measurements.
        "org/gnome/system/locale".region = import ../../../lib/locale.nix;
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          accent-color = "orange";
          clock-format = "24h";
        };
        # Ubuntu exposes all three window controls on the right.
        "org/gnome/desktop/wm/preferences".button-layout = "appmenu:minimize,maximize,close";
        "org/gnome/mutter" = {
          dynamic-workspaces = true;
          workspaces-only-on-primary = true;
        };
        "org/gnome/desktop/session".idle-delay = lib.hm.gvariant.mkUint32 300;
        "org/gnome/desktop/screensaver" = {
          lock-enabled = true;
          lock-delay = lib.hm.gvariant.mkUint32 0;
        };
        # Approval prompts can contain commands and private paths; keep them off
        # the lock screen while preserving full notifications in an unlocked session.
        "org/gnome/desktop/notifications".show-in-lock-screen = false;
        "org/gnome/shell/extensions/clipboard-indicator" = {
          cache-only-favorites = true; # Ordinary history stays in memory; pins still persist.
          cache-images = false;
          notify-on-copy = false;
          notify-on-cycle = false;
        };
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = map (extension: extension.extensionUuid) extensions ++ [
            # Use the host's Ubuntu Dock when present; never install a second dock.
            "ubuntu-dock@ubuntu.com"
          ];
          # Ubuntu ships renamed copies of these features. Enable only the pinned
          # upstream copies above to avoid duplicate tray icons and tiling handlers.
          disabled-extensions = [
            "ubuntu-appindicators@ubuntu.com"
            "tiling-assistant@ubuntu.com"
          ];
        };
        "org/gnome/shell/extensions/ding" = {
          show-home = false;
          show-trash = true;
          show-volumes = true;
          show-network-volumes = false;
        };
        "org/gnome/shell/extensions/tiling-assistant" = {
          enable-tiling-popup = true;
          enable-raise-tile-group = true;
        };
        # Ubuntu's default dock uses this schema. This configures that dock;
        # it does not install the separate Dash to Dock extension.
        "org/gnome/shell/extensions/dash-to-dock" = {
          dock-position = "LEFT";
          extend-height = true;
          dash-max-icon-size = 48;
          show-mounts = true;
          show-trash = true;
          dock-fixed = false; # Do not reserve a permanently visible screen edge.
          autohide = true; # Reveal the launcher when the pointer reaches it.
          intellihide = false; # Hide even when no application window overlaps it.
          manualhide = false; # Keep pointer-triggered access to the launcher.
        };
      };
    };
    # Link extensions into the standard user directory so Ubuntu's GNOME can
    # discover them without depending on NixOS's system XDG_DATA_DIRS.
    xdg.dataFile = lib.listToAttrs (
      map (extension: {
        name = "gnome-shell/extensions/${extension.extensionUuid}";
        value.source = "${extension}/share/gnome-shell/extensions/${extension.extensionUuid}";
      }) extensions
    );
    home.packages = [
      pkgs.dconf-editor
      pkgs.gnome-tweaks
    ]
    ++ extensions;
    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
