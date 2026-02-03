# One package selection for Neovim, Helix, and VS Code.
{
  pkgs,
  jdk,
  haskell ? false,
}:
let
  # The native Clojure tools no longer support Intel macOS; reuse the pinned JAR.
  clojureTool =
    name:
    if pkgs.stdenv.hostPlatform.system == "x86_64-darwin" then
      pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = [ jdk ];
        text = ''exec java -jar ${pkgs.${name}.src} "$@"'';
        meta = { inherit (pkgs.${name}.meta) description homepage license; };
      }
    else
      pkgs.${name};
in
rec {
  clojureLsp = clojureTool "clojure-lsp";
  cljfmt = clojureTool "cljfmt";
  rubyLsp = pkgs.rubyPackages_4_0.ruby-lsp;
  # This RuboCop release uses its own supported Ruby, independently of Ruby 4.
  rubocop = pkgs.rubyPackages.rubocop;
  erbFormatter = pkgs.rubyPackages_4_0.erb-formatter;
  packages =
    with pkgs;
    [
      vtsls
      typescript-language-server
      vscode-langservers-extracted
      prettier
      marksman
      lua-language-server
      stylua
      shfmt
      fish
      hclfmt
      ast-grep
      sqlite
      rubyLsp
      rubocop
      erbFormatter
      clojureLsp
      cljfmt
      racket
      terraform-ls
      tflint
      nixd
      nixfmt
      statix
    ]
    ++ pkgs.lib.optionals haskell [
      haskell-language-server
      ghc
      cabal-install
      haskellPackages.fourmolu
      haskellPackages.cabal-fmt
      hlint
    ];
}
