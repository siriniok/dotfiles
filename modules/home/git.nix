{
  flake,
  lib,
  pkgs,
  ...
}:
{
  home.shellAliases = {
    g = "git";
    lg = "lazygit";
  };

  # Load the complete alias/helper plugin from locked nixpkgs, independently of
  # the Oh My Zsh framework and prompt configuration.
  programs.zsh.plugins = [
    {
      name = "oh-my-zsh-git";
      src = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
      file = "plugins/git/git.plugin.zsh";
    }
  ];
  programs.zsh.initContent = ''
    # The standalone Git plugin expects this framework helper at command time.
    git_current_branch() {
      local branch
      branch=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
        branch=$(command git rev-parse --short HEAD 2>/dev/null) || return
      print -r -- "$branch"
    }
  '';

  programs = {
    git = {
      enable = true;
      ignores = [
        "*~"
        "*.swp"
        ".DS_Store"
      ];

      lfs.enable = true;
      settings = {
        user = {
          name = flake.config.me.fullname;
          email = flake.config.me.email;
        };
        github.user = flake.config.me.username;
        alias = {
          ci = "commit";
          # Preview ignored files without deleting them.
          show-ignored = "!git clean -ndX | ${lib.getExe pkgs.perl} -pe 's/Would remove/Ignored:/'";
          wtf = "!git-wtf"; # Checkout helper available through home.sessionPath.
        };
        core.autocrlf = "input";
        # Home Manager writes the shared ignore file under XDG_CONFIG_HOME.
        # Delta owns the pager settings; keep them out of this migration.
        color = {
          diff = {
            meta = "cyan";
            frag = "yellow reverse";
            old = "red";
            new = "green";
          };
          status = {
            added = "yellow";
            changed = "green";
            untracked = "cyan";
          };
          branch = {
            current = "yellow reverse";
            local = "yellow";
            remote = "green";
          };
          ui = "auto";
        };
        # Include the slash so the replacement produces a valid SSH URL.
        url."git@github.com:".insteadOf = "https://github.com/";
        # Branch with most recent change comes first
        branch.sort = "-committerdate";
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        difftool.sourcetree.cmd = ''opendiff "$LOCAL" "$REMOTE"'';
        mergetool.sourcetree.cmd = ''/Applications/Sourcetree.app/Contents/Resources/opendiff-w.sh "$LOCAL" "$REMOTE" -ancestor "$BASE" -merge "$MERGED"'';
      };
    };

  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      light = false;
      side-by-side = true;
      line-numbers = true;
      pager = "${pkgs.less}/bin/less --mouse --wheel-lines=3";
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      # This looks better with the kitty theme.
      gui.theme = {
        lightTheme = false;
        activeBorderColor = [
          "white"
          "bold"
        ];
        inactiveBorderColor = [ "white" ];
        selectedLineBgColor = [
          "reverse"
          "white"
        ];
      };
    };
  };

}
