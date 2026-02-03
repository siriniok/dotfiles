{ lib, pkgs, ... }:
{
  # Runtime dependencies for the functions below; jq is managed in packages.nix.
  home.packages = with pkgs; [
    coreutils
    curl
    wget
    lolcat
    ouch # Package-based replacement for universalarchive.
    catimg
  ];

  programs = {
    bash.enable = true;

    # For a full list of active aliases, run `alias`.
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting = {
        enable = true;
        # Home Manager also includes the main highlighter automatically.
        highlighters = [
          "brackets"
          "pattern"
        ];
        patterns = {
          # Declare both together: the legacy array assignment lost the first one.
          "rm -rf *" = "fg=white,bold,bg=red";
          "git push origin master" = "fg=white,bold,bg=red";
        };
      };
      enableCompletion = true;
      defaultKeymap = "viins";
      history = {
        size = 20000;
        save = 20000;
        share = true;
        ignoreDups = true;
        # Zsh uses HISTORY_IGNORE, rather than Bash's HISTIGNORE/HISTCONTROL.
        ignorePatterns = [
          "ls"
          "cd"
          "cd -"
          "pwd"
          "exit"
          "date"
          "* --help"
        ];
      };
      setOptions = [
        "INTERACTIVE_COMMENTS" # Allow comments at the prompt.
        "RM_STAR_WAIT" # Pause before confirming a wildcard rm.
        "NO_CLOBBER" # Use >! when intentionally replacing a file.
        "NO_INC_APPEND_HISTORY" # SHARE_HISTORY handles cross-session updates.
        "NO_INC_APPEND_HISTORY_TIME"
      ];
      initContent = lib.mkMerge [
        (lib.replaceStrings
          [ "@base64@" "@openssl@" "@open@" ]
          [
            (lib.getExe' pkgs.coreutils "base64")
            (lib.getExe' pkgs.openssl "openssl")
            (if pkgs.stdenv.isDarwin then "/usr/bin/open" else lib.getExe' pkgs.xdg-utils "xdg-open")
          ]
          (builtins.readFile ./shell-functions.zsh)
        )
        (lib.optionalString pkgs.stdenv.isDarwin ''
          # The standalone macos plugin expects this Oh My Zsh helper.
          open_command() { command /usr/bin/open "$@"; }
        '')
        (lib.mkBefore ''
          # Opt in with ZPROF=1 zsh -i -c exit; load before plugins/completion.
          if [[ -n "''${ZPROF:-}" ]]; then
            zmodload zsh/zprof
          fi
        '')
        ''
          # Switch from insert to command mode promptly after Escape (10 ms).
          KEYTIMEOUT=1

          # Ctrl+Z resumes a suspended job at an empty prompt. With pending
          # input, save the command line and clear the screen instead.
          zle -N _dotfiles_fancy_ctrl_z
          bindkey -M viins '^Z' _dotfiles_fancy_ctrl_z
          bindkey -M vicmd '^Z' _dotfiles_fancy_ctrl_z
          bindkey -M emacs '^Z' _dotfiles_fancy_ctrl_z

          # Complete without case sensitivity; allow omitted separators.
          zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z} r:|[._-]=* r:|=*'
          # A pasted tab inserts text instead of triggering completion.
          zstyle ':completion:*' insert-tab pending
          zstyle ':completion:*' verbose yes
          zstyle ':completion:*:descriptions' format '%F{yellow}%B--- %d%b%f'
          zstyle ':completion:*:messages' format '%d'
          zstyle ':completion:*:warnings' format '%F{red}No matches for:%f %d'
          zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
          zstyle ':completion:*' group-name ""
        ''
        (lib.mkOrder 1500 ''
          # Runtime-only overrides: their contents never enter the Nix store.
          if [[ -f "$HOME/.zshlocal" ]]; then
            source "$HOME/.zshlocal"
          fi
          if [[ -f "$HOME/.secret" ]]; then
            source "$HOME/.secret"
          fi
        '')
        (lib.mkOrder 2000 ''
          if [[ -n "''${ZPROF:-}" ]]; then
            zprof
          fi
        '')
      ];
      # Home Manager installs plugins from the locked nixpkgs input and registers
      # completion paths before compinit. Add packaged plugins to this list.
      plugins = [
        {
          name = "zsh-completions";
          src = "${pkgs.zsh-completions}/share/zsh/site-functions";
        }
      ]
      ++ lib.optionals pkgs.stdenv.isDarwin [
        {
          name = "macos";
          src = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
          file = "plugins/macos/macos.plugin.zsh";
        }
      ];
      shellAliases = {
        # ISO dates and timestamps, without loading the isodate plugin.
        isodate = "date +%Y-%m-%dT%H:%M:%S%z";
        isodate_utc = "date -u +%Y-%m-%dT%H:%M:%SZ";
        isodate_basic = "date -u +%Y%m%dT%H%M%SZ";
        unixstamp = "date +%s";
        date_locale = "date +%c";

        # Preserve the encode64 plugin's convenient short names.
        e64 = "encode64";
        ef64 = "encodefile64";
        d64 = "decode64";

        # Enable aliases to be sudo’ed
        #   http://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
        sudo = "sudo ";

        # ZSH
        zshs = "exec zsh";
        zshconfig = "$EDITOR ~/.zshrc";
        # List declared aliases, functions
        listaliases = "alias | sed 's/=.*//'";
        # Show non _prefixed functions
        listfunctions = "declare -f | grep '^[a-z].* ()' | sed 's/{$//'";

        # Shell Improvements
        _ = "sudo";
        h = "history";
        hosts = "$EDITOR /etc/hosts";
        quit = "exit";
        "cd." = "cd -P .";
        # Show $PATH in readable view
        path = ''print -rl -- "''${path[@]}"'';
        manpath = ''print -rl -- "''${manpath[@]}"'';
        # Shutdown
        shut = if pkgs.stdenv.isDarwin then "sudo /sbin/shutdown -h +45" else "shutdown -h +45";
        unshut = if pkgs.stdenv.isDarwin then "sudo /usr/bin/killall -TERM shutdown" else "shutdown -c";
        # Set a default terminal for remote servers
        ssh = "TERM=xterm-256color ssh";

        # Directories
        dotfiles = "cd \"$DOTFILES\"";
        wd = "cd \"$CODE\"";

        # tree
        els = "eza";
        elss = "eza -Gal";
        elhs = "eza -lhS";
        # Use the declared GNU tools: macOS's ls gives -G a different meaning.
        lhs = "${lib.getExe' pkgs.coreutils "ls"} --color=auto -lhS";
        lss = "${lib.getExe' pkgs.coreutils "ls"} --color=auto -al";
        lsp = "${lib.getExe' pkgs.coreutils "ls"} --color=auto -p";
        tree = "tree -A";
        treed = "tree -d";
        tree1 = "tree -d -L 1";
        tree2 = "tree -d -L 2";
        ll1 = "tree --dirsfirst -ChFL 1";
        ll2 = "tree --dirsfirst -ChFL 2";
        ll3 = "tree --dirsfirst -ChFL 3";
        ll4 = "tree --dirsfirst -ChFupDaL 1";
        ll5 = "tree --dirsfirst -ChFupDaL 2";
        ll6 = "tree --dirsfirst -ChFupDaL 3";

        # Git
        gclt = "git clone --depth=1";
        gitru = "git clean -d";
        gitrui = "git clean -di";
        gitrun = "git clean -dn";
        gnpd = "git --no-pager diff";

        # Editors
        emacs = "emacs -nw";

        # Miscellaneous
        # Display number of the current week and current date
        week = "date +%V";
        currentdate = "date \"+%m/%d/%Y\"";
        # Display external and local IPs
        ip = "curl --fail --silent --show-error https://ipinfo.io/ip";
        localips =
          if pkgs.stdenv.isDarwin then
            ''/sbin/ifconfig | ${lib.getExe pkgs.gawk} '/inet / && $2 !~ /^127\./ { print $2 }' ''
          else
            ''${lib.getExe' pkgs.iproute2 "ip"} -o -4 address show scope global | ${lib.getExe pkgs.gawk} '{ split($4, address, "/"); print address[1] }' '';
        # Download web page with all assets
        getpage = "wget --no-clobber --page-requisites --html-extension --convert-links --no-host-directories";
        # Download file with original filename
        get = "curl -O -L";
        # Display weather in terminal
        weather = "curl --fail --show-error -4 https://wttr.in";
        # Internet Speedtest
        stest = "wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip";
        # Run command every 30 seconds
        w30s = "${lib.getExe pkgs.unixtools.watch} -n 30";
        # Optional external ngrok installation; use the current CLI syntax.
        ngrok3000 = "ngrok http 3000";
        ngrok5000 = "ngrok http 5000";
        # Generate an SSL certificate
        certify = "sudo ${lib.getExe pkgs.certbot} certonly --manual --preferred-challenges dns";
      }
      // lib.optionalAttrs pkgs.stdenv.isLinux {
        # Explicit, on-demand system actions; never run during shell startup.
        rntwrk = "sudo systemctl restart NetworkManager.service";
        # Runtime adjustment only. Persist NixOS limits through boot.kernel.sysctl.
        incinotify = "sudo sysctl -w fs.inotify.max_user_watches=524288";
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        ql = "/usr/bin/qlmanage -p"; # Quick Look preview.
        coffee = "/usr/bin/caffeinate -u -t 3600"; # Keep the Mac awake for an hour.
      };
      envExtra = ''
        # Native Zsh arrays replace the legacy grep/awk path helpers.
        # Keep paths unique, and omit empty PATH entries (the current directory).
        typeset -U path manpath
        path=("''${(@)path:#}")
        # The trailing empty entry retains the system's default man search path.
        manpath=("''${manpath[@]}" /usr/local/man "")
      '';
      profileExtra = ''
        # Custom ~/.zprofile goes here
      '';
      # No Cargo login hook: Nix supplies Rust/Cargo, without sourcing rustup's env.
      logoutExtra = ''
        # Custom ~/.zlogout goes here
      '';
    };

    # Type `z <pat>` to cd to some directory
    zoxide.enable = true;

    # Better shell prompt!
    starship = {
      enable = true;
      settings = {
        username = {
          style_user = "blue bold";
          style_root = "red bold";
          format = "[$user]($style) ";
          disabled = false;
          show_always = true;
        };
        hostname = {
          ssh_only = false;
          ssh_symbol = "🌐 ";
          format = "on [$hostname](bold red) ";
          trim_at = ".local";
          disabled = false;
        };
      };
    };
  };
}
