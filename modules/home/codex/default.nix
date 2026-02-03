{ lib, pkgs, ... }:
let
  notify = pkgs.writeShellScriptBin "codex-notify" ''
    exec ${pkgs.python3}/bin/python3 ${./notify.py} \
      ${pkgs.libnotify}/bin/notify-send ${pkgs.zenity}/bin/zenity ${pkgs.glib.bin}/bin/gdbus
  '';
  handler = {
    type = "command";
    command = lib.escapeShellArg (lib.getExe notify);
    timeout = 5;
  };
in
{
  config = lib.mkIf pkgs.stdenv.isLinux {
    home.packages = [ notify ];
    home.file.".codex/hooks.json".text = builtins.toJSON {
      hooks = {
        # Wait for an explicit action; otherwise preserve Codex's normal prompt.
        PermissionRequest = [ { hooks = [ (handler // { timeout = 130; }) ]; } ];
        PreToolUse = [
          {
            matcher = "(^|.*[./])request_user_input(_async)?$";
            hooks = [ handler ];
          }
        ];
      };
    };
  };
}
