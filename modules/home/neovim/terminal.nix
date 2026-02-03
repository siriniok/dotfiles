{
  config,
  lib,
  pkgs,
  ...
}:
let
  neovim = lib.getExe' config.programs.neovim.finalPackage "nvim";
  remote = lib.getExe pkgs.neovim-remote;
  mkEditor =
    name: remoteMode:
    pkgs.writeShellApplication {
      inherit name;
      text = ''
        # Explicit CLI/API invocations retain Neovim's normal command-line behavior.
        for argument in "$@"; do
          case "$argument" in
            --) break ;;
            --headless|--embed|--listen|--server|--remote*|--version|--api-info|--help|-h)
              exec ${neovim} "$@"
              ;;
          esac
        done

        if [[ -n "''${NVIM:-}" ]]; then
          # Never start a second editor when the inherited parent socket is stale.
          exec ${remote} --nostart --servername "$NVIM" -cc new ${remoteMode} "$@"
        fi
        exec ${neovim} "$@"
      '';
    };
  editor = mkEditor "nvim-editor" "--remote-wait";
  opener = mkEditor "nvim-open" "--remote";
in
{
  home.packages = [
    pkgs.neovim-remote
    editor
    opener
  ];
  home.sessionVariables = {
    EDITOR = lib.getExe editor;
    VISUAL = lib.getExe editor;
  };
  home.shellAliases = {
    nvim = lib.getExe opener;
    v = lib.getExe opener;
    vi = lib.getExe opener;
    vim = lib.getExe opener;
    vic = "${lib.getExe opener} ~/.vimrc";
  };

}
