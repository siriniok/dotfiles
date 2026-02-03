# Verify user-session behavior through standalone Home Manager, without osConfig.
{
  home,
  lib,
  pkgs,
  system,
}:
let
  settings = home.dconf.settings;
  # Home Manager normalizes dconf values to typed GVariants before evaluation.
  unwrap =
    value:
    if lib.gvariant.isGVariant value then
      unwrap value.value
    else if builtins.isList value then
      map unwrap value
    else
      value;
  extensions = with pkgs.gnomeExtensions; [
    cloudflare-warp-toggle
    clipboard-indicator
    appindicator
    desktop-icons-ng-ding
    tiling-assistant
  ];
in
assert home.home.sessionVariables.TZ == import ../lib/timezone.nix;
if pkgs.stdenv.isLinux then
  assert home.dconf.enable;
  assert unwrap settings."org/gnome/desktop/screensaver".lock-enabled;
  assert unwrap settings."org/gnome/desktop/screensaver".lock-delay == 0;
  assert unwrap settings."org/gnome/desktop/session".idle-delay == 300;
  assert !(unwrap settings."org/gnome/desktop/notifications".show-in-lock-screen);
  assert unwrap settings."org/gnome/shell/extensions/clipboard-indicator".cache-only-favorites;
  assert !(unwrap settings."org/gnome/shell/extensions/clipboard-indicator".cache-images);
  assert unwrap settings."org/gnome/system/locale".region == import ../lib/locale.nix;
  assert
    unwrap settings."org/gnome/desktop/input-sources".sources == [
      [
        "xkb"
        "us+altgr-intl"
      ]
      [
        "xkb"
        "ua"
      ]
    ];
  assert builtins.elem pkgs.gnomeExtensions.clipboard-indicator.extensionUuid (
    unwrap settings."org/gnome/shell".enabled-extensions
  );
  assert unwrap settings."org/gnome/desktop/wm/keybindings".show-desktop == [ "<Super>d" ];
  assert unwrap settings."org/gnome/settings-daemon/plugins/media-keys".screensaver == [ "<Super>l" ];
  assert unwrap settings."org/gnome/desktop/interface".color-scheme == "prefer-dark";
  assert home.gtk.theme.name == "Yaru-dark";
  assert home.gtk.gtk4.theme == null;
  assert home.gtk.iconTheme.name == "Yaru";
  assert home.home.pointerCursor.name == "Yaru";
  assert unwrap settings."org/gnome/desktop/interface".accent-color == "orange";
  assert
    unwrap settings."org/gnome/desktop/wm/preferences".button-layout
    == "appmenu:minimize,maximize,close";
  assert builtins.all (
    extension:
    builtins.elem extension.extensionUuid (unwrap settings."org/gnome/shell".enabled-extensions)
  ) extensions;
  assert builtins.elem "ubuntu-dock@ubuntu.com" (
    unwrap settings."org/gnome/shell".enabled-extensions
  );
  assert !(unwrap settings."org/gnome/shell/extensions/dash-to-dock".dock-fixed);
  assert unwrap settings."org/gnome/shell/extensions/dash-to-dock".dock-position == "LEFT";
  assert system.services.displayManager.gdm.enable;
  assert system.services.displayManager.defaultSession == "gnome";
  # The named NixOS host is x86_64 even when the standalone home targets ARM.
  assert builtins.any (
    package: lib.getName package == "yaru"
  ) system.services.displayManager.gdm.extraPackages;
  assert !system.services.touchegg.enable;
  assert unwrap settings."org/gnome/desktop/interface".clock-format == "24h";
  assert
    unwrap settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal".binding
    == "<Super>e";
  assert
    unwrap settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/files".binding
    == "<Super>Return";
  assert builtins.elem "lv3:ralt_switch" (
    unwrap settings."org/gnome/desktop/input-sources".xkb-options
  );
  assert builtins.all (
    extension: builtins.hasAttr "gnome-shell/extensions/${extension.extensionUuid}" home.xdg.dataFile
  ) extensions;
  true
else
  assert !home.dconf.enable;
  assert home.services.skhd.enable;
  assert home.targets.darwin.defaults."com.apple.finder".FXEnableExtensionChangeWarning;
  assert home.targets.darwin.defaults.NSGlobalDomain.AppleICUForce24HourTime;
  assert home.targets.darwin.defaults."com.apple.menuextra.clock".Show24Hour;
  assert !(lib.hasAttrByPath [ "org/gnome/desktop/wm/keybindings" "show-desktop" ] settings);
  assert
    map (source: source."KeyboardLayout Name") (
      builtins.filter (
        source: source.InputSourceKind == "Keyboard Layout"
      ) home.targets.darwin.defaults."com.apple.HIToolbox".AppleEnabledInputSources
    ) == [
      "U.S."
      "Ukrainian"
    ];
  true
