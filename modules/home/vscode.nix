{
  config,
  flake,
  lib,
  pkgs,
  ...
}:
let
  tools = config.dotfiles.editorTools;
  haskellEnabled = flake.config.features.languages.haskell.enable;
  mapCommand = before: command: {
    inherit before;
    commands = [ command ];
  };
  formatter = extension: { "editor.defaultFormatter" = extension; };
  prettierLanguages = lib.genAttrs [
    "[javascript]"
    "[javascriptreact]"
    "[typescript]"
    "[typescriptreact]"
    "[html]"
    "[css]"
    "[scss]"
    "[json]"
    "[jsonc]"
    "[yaml]"
  ] (_: formatter "esbenp.prettier-vscode");
  prose = {
    "editor.wordWrap" = "on";
    "editor.lineNumbers" = "on";
  };
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = false;
    profiles.default = {
      userSettings = {
        "telemetry.telemetryLevel" = "off";
        "security.workspace.trust.enabled" = true;
        "security.workspace.trust.untrustedFiles" = "newWindow";
        # Nix owns these immutable installations; updates arrive through reviewed pins.
        "extensions.autoUpdate" = false;
        "extensions.autoCheckUpdates" = false;
        "update.mode" = "none";
        "search.followSymlinks" = false;
        "search.smartCase" = true;
        "search.exclude" = {
          "**/node_modules/**" = true;
          "**/tmp/**" = true;
          "**/*.swp" = true;
          "**/*.so" = true;
          "**/*.zip" = true;
        };
        "editor.formatOnSave" = true;
        "editor.formatOnType" = false;
        "editor.insertSpaces" = true;
        "editor.tabSize" = 2;
        "editor.detectIndentation" = true; # Respect existing files and project conventions.
        "editor.fontSize" = 14;
        "editor.fontFamily" = "'Fira Code', Menlo, Monaco, 'Courier New', monospace";
        "editor.fontLigatures" = true;
        "workbench.colorTheme" = "Tokyo Night Light";
        "window.autoDetectColorScheme" = false;
        "editor.renderWhitespace" = "all";
        "editor.cursorStyle" = "block";
        "editor.cursorSurroundingLines" = 5;
        "editor.wordWrap" = "off";
        "editor.rulers" = [ 100 ];
        "editor.lineNumbers" = "relative";
        "editor.renderLineHighlight" = "line";
        "editor.minimap.enabled" = false;
        "editor.bracketPairColorization.enabled" = true;
        "editor.guides.bracketPairs" = true;
        "editor.guides.highlightActiveIndentation" = true;
        "editor.localHistory.enabled" = true;
        "workbench.editor.enablePreview" = false;
        "workbench.editor.restoreViewState" = true;
        "window.restoreWindows" = "all";
        "files.hotExit" = "onExitAndWindowClose";
        "cSpell.enabledFileTypes" = {
          "*" = false;
          markdown = true;
          plaintext = true;
        };

        # Native VSCodeVim integration keeps VS Code's language extensions available.
        "vim.leader" = "<space>";
        "vim.useSystemClipboard" = true;
        "vim.ignorecase" = true;
        "vim.smartcase" = true;
        "vim.incsearch" = true;
        "vim.hlsearch" = true;
        "vim.smartRelativeLine" = true;
        "vim.cursorStylePerMode.insert" = "line";
        "vim.handleKeys"."<C-s>" = false;
        "vim.insertModeKeyBindingsNonRecursive" = [
          {
            before = [
              "i"
              "i"
            ];
            after = [ "<Esc>" ];
          }
        ];
        "vim.normalModeKeyBindingsNonRecursive" = [
          (mapCommand [ "<leader>" "<space>" ] "workbench.action.quickOpen")
          (mapCommand [ "<leader>" "f" "f" ] "workbench.action.quickOpen")
          (mapCommand [ "<leader>" "f" "b" ] "workbench.action.showAllEditors")
          (mapCommand [ "<leader>" "f" "r" ] "workbench.action.openRecent")
          (mapCommand [ "<leader>" "s" "g" ] "workbench.action.findInFiles")
          (mapCommand [ "<leader>" "s" "s" ] "workbench.action.gotoSymbol")
          (mapCommand [ "<leader>" "s" "S" ] "workbench.action.showAllSymbols")
          (mapCommand [ "<leader>" "e" ] "workbench.view.explorer")
          (mapCommand [ "<leader>" "g" "g" ] "workbench.view.scm")
          (mapCommand [ "<leader>" "c" "a" ] "editor.action.quickFix")
          (mapCommand [ "<leader>" "c" "r" ] "editor.action.rename")
          (mapCommand [ "<leader>" "c" "f" ] "editor.action.formatDocument")
          (mapCommand [ "<leader>" "b" "d" ] "workbench.action.closeActiveEditor")
          (mapCommand [ "<leader>" "U" ] "timeline.focus")
          (mapCommand [ "<leader>" "s" "u" ] "timeline.focus")
          (mapCommand [ "<leader>" "r" "c" ] "calva.jackIn")
          (mapCommand [ "<leader>" "r" "e" ] "calva.evaluateCurrentTopLevelForm")
          (mapCommand [ "<leader>" "o" "r" ] "workbench.action.tasks.runTask")
          (mapCommand [ "<leader>" "q" "s" ] "workbench.action.openRecent")
          (mapCommand [ "<leader>" "q" "q" ] "workbench.action.closeWindow")
          (mapCommand [ "<leader>" "w" "v" ] "workbench.action.splitEditorRight")
          (mapCommand [ "<leader>" "w" "s" ] "workbench.action.splitEditorDown")
          (mapCommand [ "<leader>" "w" "d" ] "workbench.action.closeActiveEditor")
          (mapCommand [ "g" "d" ] "editor.action.revealDefinition")
          (mapCommand [ "g" "r" "r" ] "editor.action.goToReferences")
          (mapCommand [ "g" "r" "a" ] "editor.action.quickFix")
          (mapCommand [ "g" "r" "n" ] "editor.action.rename")
          (mapCommand [ "g" "r" "i" ] "editor.action.goToImplementation")
          (mapCommand [ "g" "r" "t" ] "editor.action.goToTypeDefinition")
          (mapCommand [ "H" ] "workbench.action.previousEditor")
          (mapCommand [ "L" ] "workbench.action.nextEditor")
          {
            before = [
              "o"
              "o"
            ];
            after = [
              "o"
              "<Esc>"
            ];
          }
          {
            before = [
              "O"
              "O"
            ];
            after = [
              "O"
              "<Esc>"
            ];
          }
        ];
        "vim.visualModeKeyBindingsNonRecursive" = [
          (mapCommand [ "<leader>" "c" "a" ] "editor.action.quickFix")
          (mapCommand [ "<leader>" "c" "f" ] "editor.action.formatSelection")
        ];

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = lib.getExe pkgs.nixd;
        "nix.serverSettings".nixd.formatting.command = [ (lib.getExe pkgs.nixfmt) ];
        "nix.formatterPath" = lib.getExe pkgs.nixfmt;
        "shellcheck.executablePath" = lib.getExe pkgs.shellcheck;
        "prettier.prettierPath" = "${pkgs.prettier}/lib/node_modules/prettier";
        "eslint.format.enable" = false; # Prettier formats web files; ESLint diagnoses them.
        "eslint.validate" = [
          "javascript"
          "javascriptreact"
          "typescript"
          "typescriptreact"
        ];
        "rubyLsp.rubyVersionManager".identifier = "none";
        "rubyLsp.rubyExecutablePath" = lib.getExe' pkgs.ruby_4_0 "ruby";
        "rubyLsp.formatter" = "none"; # The independent RuboCop server owns formatting/diagnostics.
        "rubyLsp.linters" = [ ];
        "rubocop.mode" = "onlyRunGlobally";
        "rubocop.commandPath" = lib.getExe tools.rubocop;
        "calva.clojureLspPath" = lib.getExe tools.clojureLsp;
        "calva.paredit.defaultKeyMap" = "none"; # Avoid overriding the Vim editing map.
        "rust-analyzer.server.path" = lib.getExe pkgs.rust-analyzer;
        "rust-analyzer.check.command" = "clippy";
        "terraform.languageServer.path" = lib.getExe pkgs.terraform-ls;
        "magicRacket.general.racketPath" = lib.getExe' pkgs.racket "racket";
        "magicRacket.general.racoPath" = lib.getExe' pkgs.racket "raco";
        "[nix]" = formatter "jnoortheen.nix-ide";
        "[ruby]" = formatter "rubocop.vscode-rubocop";
        "[clojure]" = formatter "betterthantomorrow.calva";
        "[rust]" = formatter "rust-lang.rust-analyzer";
        "[haskell]" =
          if haskellEnabled then formatter "haskell.haskell" else { "editor.formatOnSave" = false; };
        "[terraform]" = formatter "hashicorp.terraform";
        "[terraform-vars]" = formatter "hashicorp.terraform";
        "[markdown]" = prose // formatter "esbenp.prettier-vscode";
        "[plaintext]" = prose // {
          "editor.formatOnSave" = false;
        };
        "[git-commit]" = prose // {
          "editor.formatOnSave" = false;
        };
      }
      // prettierLanguages
      // lib.optionalAttrs haskellEnabled {
        "haskell.manageHLS" = "PATH";
        "haskell.serverExecutablePath" =
          lib.getExe' pkgs.haskell-language-server "haskell-language-server-wrapper";
        "haskell.formattingProvider" = "fourmolu";
      };
      extensions =
        (with pkgs.vscode-extensions; [
          enkia.tokyo-night
          esbenp.prettier-vscode
          shopify.ruby-lsp
          (betterthantomorrow.calva.override { clojure-lsp = tools.clojureLsp; })
          rust-lang.rust-analyzer
          hashicorp.terraform
          eugleo.magic-racket
          tamasfe.even-better-toml
        ])
        ++ lib.optionals haskellEnabled (
          with pkgs.vscode-extensions;
          [
            haskell.haskell
            justusadam.language-haskell
          ]
        )
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ../../lib/vscode-marketplace.nix);
    };
  };
}
