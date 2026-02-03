# Editor reference

[← README](../README.md)

- [Neovim languages](#neovim-languages)
- [Emacs and MIT Scheme](#emacs-and-mit-scheme)

## Neovim languages

[neovim/default.nix](../modules/home/neovim/default.nix) composes the LazyVim extras,
shared tools, and additional parsers. Editor defaults live in
[options.nix](../modules/home/neovim/options.nix), mappings and autocmds in
[editing.nix](../modules/home/neovim/editing.nix), and plugin overrides in
[plugins.nix](../modules/home/neovim/plugins.nix). The legacy `.vimrc` is independent and
is not sourced by LazyVim.

`rainbow-delimiters.nvim` colours nested delimiters using Treesitter. Nix pins
the plugin, which loads when editing files with supported parsers.

Additional Vim plugins are also pinned through Nix:

| Plugin   | Commands / keys                                                   |
| -------- | ----------------------------------------------------------------- |
| Fugitive | `:Git`, `:Gdiffsplit`, `:Gread`, `:Gwrite`                        |
| Dispatch | `:Dispatch`, `:Make`, `:Start`; uses the Neovim adapter           |
| Jack-in  | `:Clj`, `:Lein`, `:Boot` start Clojure REPLs for use with Conjure |

The shared unfree allowlist names Jack-in explicitly because the locked nixpkgs
classifies its license as unfree.

Helix and VS Code follow the same editing defaults: a light Tokyo Night theme,
relative line numbers, two-space indentation, a column-100 ruler, five lines of
scroll context, visible whitespace, and wrapping for prose instead of code.
All three editors use the package selection in [editor-tools.nix](../lib/editor-tools.nix),
including the Intel macOS Clojure JAR fallback. Project dependencies and formatter
configuration still apply. Rust retains its standard four-space indentation.

| Action                        | LazyVim                     | Helix                                  | VS Code with Vim mode                                 |
| ----------------------------- | --------------------------- | -------------------------------------- | ----------------------------------------------------- |
| Find files                    | `Space f f`                 | `Space f f`                            | `Space f f`                                           |
| Open buffers/editors          | `Space f b`                 | `Space f b`                            | `Space f b`                                           |
| Search project                | `Space s g`                 | `Space s g`                            | `Space s g`                                           |
| Symbols                       | `Space s s`                 | `Space s s`                            | `Space s s`                                           |
| Code action / rename / format | `Space c a/r/f`             | `Space c a/r/f`                        | `Space c a/r/f`                                       |
| Close buffer/editor           | `Space b d`                 | `Space b d`                            | `Space b d`                                           |
| Git                           | Lazygit/Fugitive            | Changed-files picker (`Space g g`)     | Source Control (`Space g g`)                          |
| History/session recovery      | Undo picker and Persistence | Native undo during the running session | Timeline (`Space U`), local history, restored windows |

`ii` leaves insert mode in all three. Helix keeps its selection-first model and
native commands; it does not run Neovim plugins, embedded REPLs, or Persistence
sessions. VS Code uses Calva for Clojure REPL/Paredit (`Space r c` to jack in,
`Space r e` to evaluate a top-level form), native tasks (`Space o r`), Ruby LSP
plus an independent Nix RuboCop server, Rust Analyzer, Haskell, Terraform, and
Magic Racket. Racket syntax/indentation are configured; its separate
`racket-langserver` package is not installed by this configuration.

VS Code language/theme extensions come from locked nixpkgs; additional Marketplace
pins live in [vscode-marketplace.nix](../lib/vscode-marketplace.nix). The scheduled
extension updater changes only that pin file. Nix IDE owns Nix syntax and
formatting, replacing the redundant legacy Nix syntax/formatter extensions.
The updater is written in Janet, reads Marketplace manifests, and hashes each
version-specific VSIX once. It reports progress and preserves existing pins if
any update fails; the weekly workflow runs it with the pinned Nix toolchain.

Home Manager also owns the Neovim executable and its tool/Lua dependency wrapper.
NixOS does not install a competing editor, and user profiles precede system
packages in `PATH`. After applying changes, restart the shell and Neovim.

Inside Neovim's `:terminal`, `nvim`, `v`, `vi`, and `vim` open files in a split
of the parent editor using the pinned `nvr` client. `EDITOR` and `VISUAL` use
`nvim-editor`, which waits for editing to finish so commands such as `git commit`
resume at the right time. Save and close the edit with `:wq`; modified buffers
are preserved when hidden. Normal terminals and SSH sessions start Neovim
directly. Explicit `--headless`, server/API, and version/help invocations retain
normal Neovim CLI behavior. A stale parent socket reports an error rather than
starting another interactive editor. This uses `$NVIM`, so the old
`NVIM_LISTEN_ADDRESS` editor block is unnecessary.

LazyVim's `persistence.nvim` saves project sessions on normal exit once a file
buffer is open. Sessions live under `~/.local/state/nvim/sessions` by default,
with separate sessions for directories and Git branches. Restore with
`Space q s` (current project), `Space q S` (choose), or `Space q l` (last session).
`Space q d` disables saving for the current session. Startup does not restore a
session automatically.

Code uses two-space indentation with spaces and no wrapping; Markdown, plain
text, and Git commit buffers wrap at word boundaries. `ii` leaves insert mode
or cancels the command line; visual `v` retains its usual behavior. Insert-mode
`Ctrl+U` and `Ctrl+W` create an undo boundary before deletion. Normal-mode `oo`
and `OO` add a blank line below or above without remaining in insert mode.

| Languages                               | Editor support                                                                                                  |
| --------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| JavaScript, TypeScript, React (JSX/TSX) | vtsls, ESLint, Prettier                                                                                         |
| HTML, CSS                               | VS Code language servers, Prettier                                                                              |
| Ruby                                    | Ruby LSP and ERB formatter on Ruby 4; RuboCop with its packaged runtime                                         |
| Clojure                                 | clojure-lsp, cljfmt, Conjure REPL, Paredit                                                                      |
| Rust                                    | rust-analyzer, rustfmt/Clippy, Rustaceanvim                                                                     |
| Racket                                  | Racket parser and Conjure stdio REPL                                                                            |
| Terraform                               | terraform-ls, Terraform formatting, TFLint                                                                      |
| Nix                                     | nixd, nixfmt, Statix                                                                                            |
| Haskell (optional; currently disabled)  | Haskell Language Server, Fourmolu, HLint, GHC/Cabal REPL tools; enable with `features.languages.haskell.enable` |

Tools come from Nix, with Mason disabled. Intel macOS uses the pinned
clojure-lsp/cljfmt JARs on the configured JDK because their native builds no
longer support that platform. Project environments can override tools through
direnv; Haskell projects should supply a matching GHC/HLS toolchain when using
a different compiler version. ESLint follows each project's configuration and
dependencies; Prettier owns web formatting.

Lazy itself is bootstrapped from Nix, and runtime plugin installation/update
checks are disabled. Its build/help-tag tasks skip store paths; Nix supplies
those artifacts. Change extras in the Nix module and update through the flake.
The old `~/.config/nvim/lazyvim.json` is retained but no longer selects extras;
writable news/UI state lives in Neovim's state directory as `lazyvim-nix.json`.
Blink's fuzzy library and LuaSnip's regex library are built/provided by Nix.
The diff highlight query follows the pinned diff grammar. Health checks can
still report optional image/PDF/LaTeX rendering, Hoogle/debugger dependencies,
and the Nix-managed `pack/hm` directory; these do not prevent editing code.

Racket support does not install `racket-langserver`; it is not packaged by the
pinned nixpkgs input. Conjure starts Racket directly without downloading packages
at startup. Clojure REPL evaluation connects to your project's nREPL server.
Terraform's CLI is explicitly allowed under the shared unfree predicate for its
Business Source License. Apply with `j run`, then restart Neovim.

Codex is available through the Nix-managed CLI and Sidekick integration in
[neovim/codex.nix](../modules/home/neovim/codex.nix). Run `:Codex` or press
`<leader>ac` to toggle its terminal; `<leader>af` sends the current file and
visual `<leader>av` sends the selection. Review the inserted context and press
Enter to submit. `<C-.>` switches focus; inside the Codex terminal it hides the
window. The leader is Space with the default LazyVim keymap.

This uses Neovim's terminal with Copilot/next-edit suggestions and multiplexer
support disabled. It uses your normal Codex configuration and sign-in. If needed,
run `codex login` following the [official authentication guide](https://developers.openai.com/codex/auth).

## Emacs and MIT Scheme

Emacs keeps loading the legacy `modules/home/tilde/.emacs` through a managed
`~/.emacs` wrapper. Nix supplies Paredit, Git Gutter, Scheme Complete, and the
Twilight Bright theme it uses. On Linux, MIT/GNU Scheme is installed through
`pkgs.mitscheme`, and the wrapper replaces the old Homebrew command with the Nix
executable. The locked package does not support Darwin; macOS keeps using
`mit-scheme` from PATH.
