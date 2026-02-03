{
  config,
  flake,
  lib,
  pkgs,
  ...
}:
let
  tools = config.dotfiles.editorTools;
  haskell = flake.config.features.languages.haskell.enable;
  server = package: executable: args: {
    command = lib.getExe' package executable;
    inherit args;
  };
  prettier = {
    command = lib.getExe pkgs.prettier;
    args = [
      "--stdin-filepath"
      "%{buffer_name}"
    ];
  };
  language = name: servers: {
    inherit name;
    language-servers = servers;
    auto-format = true;
    indent = {
      tab-width = 2;
      unit = "  ";
    };
  };
in
{
  programs.helix = {
    enable = true;
    defaultEditor = false; # Neovim owns EDITOR, including nested-terminal handling.
    extraPackages = tools.packages;
    settings = {
      theme = "tokyonight_day";
      editor = {
        true-color = true;
        line-number = "relative";
        cursorline = true;
        scrolloff = 5;
        rulers = [ 100 ];
        text-width = 100;
        auto-format = true;
        bufferline = "multiple";
        color-modes = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        search = {
          smart-case = true;
          wrap-around = true;
        };
        whitespace = {
          render = "all";
          characters = {
            space = "·";
            nbsp = "·";
            tab = "▸";
            tabpad = "·";
            newline = "⏎";
          };
        };
        indent-guides.render = true;
        soft-wrap = {
          enable = false;
          wrap-indicator = "↳·";
        };
        file-picker.hidden = false; # Include dotfiles, while respecting ignore files.
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
          display-signature-help-docs = true;
        };
      };
      keys = {
        insert = {
          i.i = "normal_mode"; # Match LazyVim's ii escape chord.
          "C-s" = [
            ":write"
            "normal_mode"
          ];
          "C-w" = [
            "commit_undo_checkpoint"
            "delete_word_backward"
          ];
          "C-u" = [
            "commit_undo_checkpoint"
            "kill_to_line_start"
          ];
        };
        normal = {
          "C-s" = ":write";
          H = ":buffer-previous";
          L = ":buffer-next";
          space = {
            space = "file_picker";
            e = "file_picker_in_current_buffer_directory";
            f = {
              f = "file_picker";
              b = "buffer_picker";
            };
            s = {
              g = "global_search";
              s = "symbol_picker";
              S = "workspace_symbol_picker";
            };
            c = {
              a = "code_action";
              r = "rename_symbol";
              f = ":format";
            };
            b.d = ":buffer-close";
            g.g = "changed_file_picker"; # Native Git changes picker; Helix has no embedded terminal.
            q.q = ":quit-all";
            w = {
              s = ":hsplit";
              v = ":vsplit";
              d = ":quit";
            };
          };
        };
      };
    };
    languages = {
      language-server = {
        typescript-language-server = server pkgs.typescript-language-server "typescript-language-server" [
          "--stdio"
        ];
        vscode-html-language-server =
          server pkgs.vscode-langservers-extracted "vscode-html-language-server"
            [ "--stdio" ];
        vscode-css-language-server = server pkgs.vscode-langservers-extracted "vscode-css-language-server" [
          "--stdio"
        ];
        vscode-json-language-server =
          server pkgs.vscode-langservers-extracted "vscode-json-language-server"
            [ "--stdio" ];
        vscode-eslint =
          (server pkgs.vscode-langservers-extracted "vscode-eslint-language-server" [ "--stdio" ])
          // {
            config = {
              validate = "on";
              run = "onType";
              format = false;
              workingDirectory.mode = "auto";
              codeActionOnSave = {
                enable = false;
                mode = "all";
              };
              codeAction = {
                disableRuleComment = {
                  enable = true;
                  location = "separateLine";
                };
                showDocumentation.enable = true;
              };
            };
          };
        ruby-lsp = server tools.rubyLsp "ruby-lsp" [ ];
        rubocop = server tools.rubocop "rubocop" [ "--lsp" ];
        clojure-lsp = server tools.clojureLsp "clojure-lsp" [ ];
        rust-analyzer = (server pkgs.rust-analyzer "rust-analyzer" [ ]) // {
          config.check.command = "clippy";
        };
        terraform-ls = server pkgs.terraform-ls "terraform-ls" [ "serve" ];
        nixd = server pkgs.nixd "nixd" [ ];
        marksman = server pkgs.marksman "marksman" [ "server" ];
        lua-language-server = server pkgs.lua-language-server "lua-language-server" [ ];
      }
      // lib.optionalAttrs haskell {
        haskell-language-server = server pkgs.haskell-language-server "haskell-language-server-wrapper" [
          "--lsp"
        ];
      };
      language =
        map
          (
            name:
            (language name [
              "typescript-language-server"
              "vscode-eslint"
            ])
            // {
              formatter = prettier;
            }
          )
          [
            "javascript"
            "jsx"
            "typescript"
            "tsx"
          ]
        ++ [
          ((language "html" [ "vscode-html-language-server" ]) // { formatter = prettier; })
          ((language "css" [ "vscode-css-language-server" ]) // { formatter = prettier; })
          ((language "json" [ "vscode-json-language-server" ]) // { formatter = prettier; })
          (language "ruby" [
            {
              name = "ruby-lsp";
              except-features = [ "format" ];
            }
            "rubocop"
          ])
          (
            (language "clojure" [ "clojure-lsp" ])
            // {
              formatter = {
                command = lib.getExe tools.cljfmt;
                args = [
                  "fix"
                  "-"
                ];
              };
            }
          )
          (
            (language "rust" [ "rust-analyzer" ])
            // {
              indent = {
                tab-width = 4;
                unit = "    ";
              };
            }
          )
          (
            (language "haskell" (lib.optional haskell "haskell-language-server"))
            // {
              auto-format = haskell;
            }
            // lib.optionalAttrs haskell {
              formatter = {
                command = lib.getExe pkgs.haskellPackages.fourmolu;
                args = [
                  "--stdin-input-file"
                  "%{buffer_name}"
                ];
              };
            }
          )
          ((language "nix" [ "nixd" ]) // { formatter.command = lib.getExe pkgs.nixfmt; })
          (language "hcl" [ "terraform-ls" ])
          (language "tfvars" [ "terraform-ls" ])
          # Racket syntax/indentation are built in; racket-langserver is a separate Racket package.
          ((language "racket" [ ]) // { auto-format = false; })
          (
            (language "lua" [ "lua-language-server" ])
            // {
              formatter = {
                command = lib.getExe pkgs.stylua;
                args = [ "-" ];
              };
            }
          )
          (
            (language "markdown" [ "marksman" ])
            // {
              formatter = prettier;
              soft-wrap.enable = true;
            }
          )
          (
            (language "git-commit" [ ])
            // {
              auto-format = false;
              soft-wrap.enable = true;
            }
          )
          (
            (language "text" [ ])
            // {
              scope = "text.plain";
              file-types = [ "txt" ];
              auto-format = false;
              soft-wrap.enable = true;
            }
          )
        ];
    };
  };
}
