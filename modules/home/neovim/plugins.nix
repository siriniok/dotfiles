{ lib, pkgs, ... }:
let
  lazyManager = pkgs.vimPlugins.lazy-nvim;
in
{
  programs.lazyvim.plugins.languages = ''
    return {
      {
        "tpope/vim-fugitive",
        dir = "${pkgs.vimPlugins.vim-fugitive}",
        dev = false,
        pin = true,
        event = "LazyFile",
        cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite" },
      },
      {
        "tpope/vim-dispatch",
        dir = "${pkgs.vimPlugins.vim-dispatch}",
        dev = false,
        pin = true,
        lazy = false, -- Register build commands before the Neovim adapter loads.
      },
      {
        "radenling/vim-dispatch-neovim",
        dir = "${pkgs.vimPlugins.vim-dispatch-neovim}",
        dev = false,
        pin = true,
        lazy = false, -- Run Dispatch jobs through Neovim's terminal and job APIs.
        dependencies = { "tpope/vim-dispatch" },
      },
      {
        "clojure-vim/vim-jack-in",
        dir = "${pkgs.vimPlugins.vim-jack-in}",
        dev = false,
        pin = true,
        ft = "clojure",
        cmd = { "Clj", "Lein", "Boot" },
        dependencies = { "tpope/vim-dispatch", "radenling/vim-dispatch-neovim" },
      },
      {
        "HiPhish/rainbow-delimiters.nvim",
        dir = "${pkgs.vimPlugins.rainbow-delimiters-nvim}",
        dev = false,
        pin = true,
        event = "LazyFile", -- Colour nested delimiters using the installed Treesitter parsers.
      },
      {
        "folke/snacks.nvim",
        opts = {
          picker = {
            db = {
              sqlite3_path = "${lib.getLib pkgs.sqlite}/lib/libsqlite3${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}",
            },
          },
        },
      },
      {
        "saghen/blink.cmp",
        dir = "${pkgs.vimPlugins.blink-cmp}",
        dev = false,
        pin = true,
        build = false, -- Nix builds the native fuzzy matcher.
      },
      {
        "folke/lazy.nvim",
        dir = "${lazyManager}",
        dev = false,
        pin = true,
      },
      {
        "catppuccin/nvim",
        name = "catppuccin",
        dir = "${pkgs.vimPlugins.catppuccin-nvim}",
        dev = false,
        pin = true,
      },
      -- This lazyvim-nix revision omits these transitive snippet dependencies.
      -- Explicit store paths keep the shared snippet engine and Blink usable offline.
      {
        "L3MON4D3/LuaSnip",
        dir = "${pkgs.vimPlugins.luasnip}",
        pin = true,
      },
      {
        "rafamadriz/friendly-snippets",
        dir = "${pkgs.vimPlugins.friendly-snippets}",
        pin = true,
      },
      {
        "neovim/nvim-lspconfig",
        opts = {
          servers = {
            html = {},
            cssls = {},
            -- EDN uses the clojure filetype; JSX/TSX use *react filetypes.
            clojure_lsp = { filetypes = { "clojure" } },
            vtsls = {
              filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
            },
            -- The Nix extra defaults to nil; run only our selected server.
            nil_ls = { enabled = false },
            nixd = {},
          },
        },
      },
      {
        "stevearc/conform.nvim",
        opts = {
          formatters_by_ft = {
            clojure = { "cljfmt" },
            hcl = { "hcl" }, -- General HCL formatter; no Packer dependency.
          },
        },
      },
      {
        "mfussenegger/nvim-lint",
        opts = {
          linters_by_ft = {
            terraform = { "tflint" },
            tf = { "tflint" },
          },
        },
      },
    }
  '';
}
