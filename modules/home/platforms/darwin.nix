# macOS user preferences and terminal integration, independent of nix-darwin.
{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  services.skhd = {
    enable = true;
    outLogFile = "${config.home.homeDirectory}/Library/Logs/skhd.log";
    errorLogFile = "${config.home.homeDirectory}/Library/Logs/skhd.err.log";
    config = ''
      # Command+E opens Ghostty; physical keycodes work with either input language.
      cmd - 0x0E : /usr/bin/open -a ${lib.escapeShellArg "${config.programs.ghostty.package}/Applications/Ghostty.app"}
      # Command+Enter opens the user's home directory in Finder (Return = 0x24).
      cmd - 0x24 : /usr/bin/open -a Finder ${lib.escapeShellArg config.home.homeDirectory}
    '';
  };

  # User preferences also apply when using standalone Home Manager on macOS.
  targets.darwin.defaults = {
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleICUForce24HourTime = true;
    "com.apple.menuextra.clock" = {
      Show24Hour = true;
      ShowAMPM = false;
    };
    "com.apple.HIToolbox".AppleEnabledInputSources = [
      {
        InputSourceKind = "Keyboard Layout";
        "KeyboardLayout ID" = 0;
        "KeyboardLayout Name" = "U.S.";
      }
      {
        InputSourceKind = "Keyboard Layout";
        "KeyboardLayout ID" = 19518;
        "KeyboardLayout Name" = "Ukrainian";
      }
      {
        # Keep the emoji/symbol viewer available; this is not another layout.
        InputSourceKind = "Non Keyboard Input Method";
        "Bundle ID" = "com.apple.CharacterPaletteIM";
      }
    ];
    "com.apple.dock" = {
      autohide = true;
      wvous-tl-corner = 2; # Top left: Mission Control.
      wvous-bl-corner = 3; # Bottom left: application windows.
      wvous-br-corner = 4; # Bottom right: desktop.
    };
    "com.apple.finder" = {
      _FXShowPosixPathInTitle = true;
      FXEnableExtensionChangeWarning = true;
      QuitMenuItem = true;
      ShowPathbar = true;
      ShowStatusBar = true;
    };
  };

  # Includes actual italic faces, installed into ~/Library/Fonts by Home Manager.
  home.packages = [
    pkgs.jetbrains-mono
    # Modern iTerm2 terminfo; terminal applications keep their own entries on overlap.
    (lib.lowPrio pkgs.ncurses)
  ];
  home.file."Library/Application Support/iTerm2/DynamicProfiles/nix.json".text = builtins.toJSON {
    Profiles = [
      {
        Name = "Nix";
        Guid = "12bd2e30-f8cc-4c4a-af35-9599295a976b";
        "Use Italic Font" = true;
        "Normal Font" = "JetBrainsMono-Regular 12";
        "Non Ascii Font" = "JetBrainsMono-Regular 12";
        "Use Non-ASCII Font" = false;
        "Terminal Type" = "xterm-256color";
      }
    ];
  };
}
