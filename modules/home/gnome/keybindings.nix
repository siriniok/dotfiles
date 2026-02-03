# User GNOME shortcuts apply on NixOS and standalone Home Manager (including Ubuntu).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  emptyShortcuts = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
  sessionBindings = {
    "org/gnome/mutter" = {
      # Command is a modifier, so tapping it alone must not open overview.
      overlay-key = "";
    };
    "org/gnome/desktop/wm/keybindings" = {
      # Command+Tab, or ordinary Option+Tab, switches applications.
      switch-applications = [
        "<Super>Tab"
        "<Alt>Tab"
      ];
      # Command+Shift+Tab, or Option+Shift+Tab, switches applications backward.
      switch-applications-backward = [
        "<Shift><Super>Tab"
        "<Shift><Alt>Tab"
      ];
      # Command+grave emits Alt+F6 to switch windows within the current application.
      switch-group = [ "<Alt>F6" ];
      # Command+Shift+grave selects the previous window of the current application.
      switch-group-backward = [ "<Shift><Alt>F6" ];
      # Clear the default Alt+F6 cycling actions to avoid stealing switch-group.
      cycle-group = emptyShortcuts;
      # The reverse cycling action conflicts with Shift+Alt+F6 for the same reason.
      cycle-group-backward = emptyShortcuts;
      # Command+F3 or Command+Option+D toggles the desktop and restores windows.
      show-desktop = [ "<Super>d" ];
      # Command+M / Command+H minimizes the focused window, not the whole app.
      minimize = [ "<Super>m" ];
      # Ctrl+Command+F toggles fullscreen; Ctrl is physical Caps Lock.
      toggle-fullscreen = [ "<Control><Super>f" ];
      # Ctrl+Left switches to the workspace on the left.
      switch-to-workspace-left = [ "<Control><Super>Left" ];
      # Ctrl+Right switches to the workspace on the right.
      switch-to-workspace-right = [ "<Control><Super>Right" ];
      # Ctrl+Shift+Left moves the focused window one workspace left.
      move-to-workspace-left = [ "<Control><Shift><Super>Left" ];
      # Ctrl+Shift+Right moves the focused window one workspace right.
      move-to-workspace-right = [ "<Control><Shift><Super>Right" ];
    };
    "org/gnome/shell/keybindings" = {
      # Command+Space opens overview/search; Ctrl+Up is the Mission Control alias.
      toggle-overview = [
        "<Super>space"
        "<Super>F3"
      ];
      # Ctrl+Down opens the application grid, GNOME's available Expose-like view.
      toggle-application-view = [ "<Super>F4" ];
      # Command+Shift+3 takes a full-screen screenshot.
      screenshot = [ "<Shift><Super>3" ];
      # Keep the standard Option+Print shortcut for an immediate window capture.
      screenshot-window = [ "<Alt>Print" ];
      # Command+Shift+4/5 or Print opens GNOME's screenshot/recording interface.
      show-screenshot-ui = [
        "<Shift><Super>4"
        "<Shift><Super>5"
        "Print"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      # Ctrl+Command+Q emits Super+L: lock the existing session, never log out.
      screensaver = [ "<Super>l" ];
      # Command+Option+Escape opens the custom System Monitor action below.
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/system-monitor/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/files/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal" = {
      name = "Ghostty";
      command = lib.getExe config.programs.ghostty.package;
      binding = "<Super>e"; # Physical Command+E opens the terminal.
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/files" = {
      name = "Files";
      command = "${lib.getExe' pkgs.xdg-utils "xdg-open"} ${lib.escapeShellArg config.home.homeDirectory}";
      binding = "<Super>Return"; # Physical Command+Enter opens the home directory.
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/system-monitor" = {
      name = "System Monitor";
      command = lib.getExe pkgs.gnome-system-monitor;
      # keyd emits Ctrl+Shift+Escape for physical Command+Option+Escape.
      binding = "<Control><Shift>Escape";
    };
  };
in
lib.mkIf pkgs.stdenv.isLinux {
  dconf.settings = sessionBindings;
  home.packages = [ pkgs.gnome-system-monitor ];
}
