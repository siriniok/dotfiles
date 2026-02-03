{
  config,
  flake,
  lib,
  pkgs,
  ...
}:

let
  inherit (flake) inputs;
  lazyManager = pkgs.vimPlugins.lazy-nvim;
  # The integration's diff queries are newer than its own pinned parser.
  # Use the query distributed with the exact grammar from its parser manifest.
  diffSpec = (lib.importJSON "${inputs.lazyvim}/data/parser-manifest.json").parsers.diff;
  diffSource = pkgs.fetchgit {
    inherit (diffSpec) url sha256;
    rev = diffSpec.revision;
    fetchSubmodules = false;
  };
  editorTools = config.dotfiles.editorTools;
in
{
  imports = [
    inputs.lazyvim.homeManagerModules.default
    ./codex.nix
    ./terminal.nix
    ./options.nix
    ./editing.nix
    ./plugins.nix
  ];

  # The upstream starter otherwise clones lazy.nvim before reading any plugins.
  xdg.dataFile."nvim/lazy/lazy.nvim".source = lazyManager;
  xdg.configFile."nvim/queries/diff/highlights.scm".source =
    pkgs.runCommand "neovim-diff-highlights.scm" { }
      ''
        cp ${diffSource}/queries/highlights.scm "$out"
      '';

  # Neovim 0.12.4 can receive nil from the remote-version probe's wait().
  # Patch only the health module, using the selected Neovim's own runtime file.
  # If upstream already guards the result, the replacement is a no-op.
  xdg.configFile."nvim/lua/vim/health/health.lua".source = pkgs.runCommand "neovim-health.lua" { } ''
    substitute ${config.programs.neovim.package}/share/nvim/runtime/lua/vim/health/health.lua "$out" \
      --replace-quiet 'if result.code ~= 0 or' 'if result == nil or result.code ~= 0 or'
  '';

  programs.neovim = {
    defaultEditor = false; # terminal.nix owns the context-aware editor command.
    viAlias = true;
    vimAlias = true;
    extraLuaPackages = ps: [ ps.jsregexp ];
  };

  xdg.configFile."nvim/init.lua".text = lib.mkBefore ''
    -- Bootstrap from Nix, including on the very first launch.
    vim.opt.rtp:prepend("${lazyManager}")
    local lazy = require("lazy")
    local setup = lazy.setup
    lazy.setup = function(opts)
      lazy.setup = setup
      opts.install = vim.tbl_deep_extend("force", opts.install or {}, { missing = false })
      opts.checker = { enabled = false }
      opts.rocks = { enabled = false } -- Nix supplies native Lua dependencies.
      return setup(opts)
    end

    -- lazy.nvim's local-plugin tasks otherwise regenerate doc/tags and run
    -- builders in the immutable store, even for pinned development plugins.
    local tasks = require("lazy.manage.task.plugin")
    for _, name in ipairs({ "docs", "build" }) do
      local skip = tasks[name].skip
      tasks[name].skip = function(plugin, ...)
        if plugin.dir:sub(1, #"${builtins.storeDir}/") == "${builtins.storeDir}/" then
          return true
        end
        return skip(plugin, ...)
      end
    end
  '';

  programs.lazyvim = {
    enable = true;

    # Nix supplies the tools explicitly: upstream dependency metadata is incomplete
    # and its runtime defaults differ from our Ruby/Node/Rust configuration.
    extras = {
      coding = {
        blink.enable = true;
        luasnip.enable = true;
      };
      lang = {
        typescript.enable = true; # JavaScript, TypeScript, JSX and TSX/React.
        ruby.enable = true;
        clojure.enable = true; # Conjure REPL and structural editing.
        rust.enable = true;
        terraform.enable = true;
        nix.enable = true;
        haskell.enable = flake.config.features.languages.haskell.enable;
      };
      formatting.prettier.enable = true;
      linting.eslint.enable = true;
    };

    extraPackages = editorTools.packages;

    # HTML/CSS/Racket have no dedicated extras in this pinned LazyVim release.
    treesitterParsers = with pkgs.vimPlugins.nvim-treesitter-parsers; [
      html
      css
      racket
    ];

  };
}
