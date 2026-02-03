{
  lib,
  stdenvNoCC,
  importNpmLock,
  nodejs,
  makeWrapper,
}:
let
  package = lib.importJSON ./package.json;
  nodeModules = importNpmLock.buildNodeModules {
    npmRoot = ./.;
    inherit nodejs;
  };
in
stdenvNoCC.mkDerivation {
  pname = "trash-cli-sindresorhus";
  version = package.dependencies.trash-cli;
  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    makeWrapper ${lib.getExe nodejs} "$out/bin/trash" \
      --add-flags ${nodeModules}/node_modules/trash-cli/cli.js
    runHook postInstall
  '';
  meta = {
    description = "Move files to the trash using Sindre Sorhus's trash-cli";
    homepage = "https://github.com/sindresorhus/trash-cli";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "trash";
  };
}
