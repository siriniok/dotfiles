# Shared GNOME keyboard data for user sessions and the system greeter.
{
  lib,
  xkb ? {
    layout = "us,ua";
    variant = "altgr-intl,";
    options = lib.concatStringsSep "," [
      "terminate:ctrl_alt_bksp"
      "grp:sclk_toggle"
      "lv3:ralt_switch"
      "compose:menu"
    ];
  },
}:
let
  # GDM's dconf serializer requires an explicit element type for empty arrays.
  emptyShortcuts = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
  layouts = lib.splitString "," xkb.layout;
  variants = lib.splitString "," xkb.variant;
  inputSources = lib.imap0 (
    index: layout:
    let
      variant = if index < builtins.length variants then builtins.elemAt variants index else "";
    in
    lib.gvariant.mkTuple [
      "xkb"
      (layout + lib.optionalString (variant != "") "+${variant}")
    ]
  ) layouts;
  inputBindings = {
    "org/gnome/desktop/input-sources" = {
      sources = inputSources;
      # Use XKB's direct layout toggle instead of GNOME's modal source switcher.
      xkb-options = lib.filter (option: option != "") (lib.splitString "," xkb.options);
    };
    "org/gnome/desktop/wm/keybindings" = {
      # Physical left Ctrl switches through XKB; keep the dedicated hardware key.
      switch-input-source = [ "XF86Keyboard" ];
      # Clear the old Shift+F13 popup binding; both directions toggle EN/UK.
      switch-input-source-backward = emptyShortcuts;
    };
  };
in
{
  inherit xkb;
  settings = inputBindings;
}
