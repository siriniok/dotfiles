# Check that a feature switch controls package roots and every editor together.
{
  home,
  features,
  lib,
  pkgs,
}:
let
  names = map lib.getName home.home.packages;
  has = name: builtins.elem name names;
  haskell = features.languages.haskell.enable;
  extensions = map (
    extension: extension.vscodeExtUniqueId
  ) home.programs.vscode.profiles.default.extensions;
  language = lib.findFirst (
    entry: entry.name == "haskell"
  ) null home.programs.helix.languages.language;
  supported = package: lib.meta.availableOn pkgs.stdenv.hostPlatform package;
in
assert has "ghc" == haskell;
assert has "haskell-language-server" == haskell;
assert has "cabal-install" == haskell;
assert has "fourmolu" == haskell;
assert has "cabal-fmt" == haskell;
assert has "hlint" == haskell;
assert home.programs.lazyvim.extras.lang.haskell.enable == haskell;
assert builtins.elem "haskell.haskell" extensions == haskell;
assert builtins.elem "justusadam.language-haskell" extensions == haskell;
assert
  builtins.hasAttr "haskell.serverExecutablePath" home.programs.vscode.profiles.default.userSettings
  == haskell;
assert builtins.elem "haskell-language-server" language.language-servers == haskell;
assert language.auto-format == haskell;
assert has "gitbutler" == features.apps.gitbutler.enable;
assert
  has "microsoft-edge" == (features.apps.microsoftEdge.enable && supported pkgs.microsoft-edge);
assert
  has "android-studio" == (features.apps.androidStudio.enable && supported pkgs.android-studio);
true
