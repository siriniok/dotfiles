{ lib, pkgs, ... }:
let
  schemeSupported = lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.mitscheme;
  schemeCommand = if schemeSupported then lib.getExe' pkgs.mitscheme "mit-scheme" else "mit-scheme";
in
{
  home.packages = lib.optional schemeSupported pkgs.mitscheme;

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.nix-mode
      epkgs.magit
      epkgs.paredit
      epkgs.git-gutter
      epkgs.scheme-complete
      epkgs.twilight-bright-theme
    ];
  };

  # Keep the legacy init file in use without editing its contents. Override its
  # old Homebrew paths after loading; Nix's Scheme wrapper finds its own library.
  home.file.".emacs".text = ''
    (require 'git-gutter)
    (load "${./tilde/.emacs}" nil t t)
    (setq scheme-program-name "${schemeCommand} --heap 10000")
  '';
}
