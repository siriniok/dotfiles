# System-wide keyboard mapping belongs to macOS; user defaults live in Home Manager.
{ flake, lib, ... }:
{
  # nix-darwin installs these native apps through an existing Homebrew installation.
  homebrew = {
    enable = true;
    casks = [
      "clipy" # Clipboard history and reusable snippets.
      "coconutbattery" # Battery health and charging information.
      "the-unarchiver" # Finder archive extraction.
      "iterm2" # Alternative terminal alongside Ghostty.
      "qlmarkdown" # Render Markdown in Quick Look.
      "syntax-highlight" # Highlight source code in Quick Look.
      "quicklook-video" # Preview additional video formats.
      "suspicious-package" # Inspect installer files and scripts before installation.
      "dash" # Offline API documentation browser.
      "gitup-app" # GitUp's current cask token.
      "figma" # Official macOS app; Linux uses the community client.
      "google-drive" # Official sync client is unavailable on Linux.
      "vimr" # Native macOS Neovim GUI.
      "gimp" # Official macOS image editor, owned here instead of Home Manager.
      "vlc" # Official macOS media player, owned here instead of Home Manager.
    ]
    ++ lib.optional flake.config.features.apps.androidStudio.enable "android-studio";
  };

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
}
