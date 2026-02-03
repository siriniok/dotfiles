{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  gtk3,
  webkitgtk_4_1,
  libsoup_3,
  glib,
  dbus,
  cairo,
  gdk-pixbuf,
}:
let
  darwin = stdenvNoCC.hostPlatform.isDarwin;
  assets = {
    x86_64-linux = {
      file = "Kueri_0.6.0_amd64.deb";
      sha256 = "7c2d90dc417dbcdedf223f6598ac551922338bc24009fe8facdf427e8ab3edc0";
    };
    aarch64-darwin = {
      file = "Kueri_aarch64.app.tar.gz";
      sha256 = "390aba0fabc2e7f34d4561f783a8af99f919a50c896cad387676cf6a919d8499";
    };
    x86_64-darwin = {
      file = "Kueri_x64.app.tar.gz";
      sha256 = "8be4d22ccb497e62a0f3927214e742bc788352387cad1e5ff4b94de83087bdb2";
    };
  };
  asset = assets.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kueri";
  version = "0.6.0";
  src = fetchurl {
    url = "https://github.com/umarta/kueri/releases/download/v${finalAttrs.version}/${asset.file}";
    inherit (asset) sha256;
  };

  nativeBuildInputs = lib.optionals (!darwin) [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];
  buildInputs = lib.optionals (!darwin) [
    gtk3
    webkitgtk_4_1
    libsoup_3
    glib
    dbus
    cairo
    gdk-pixbuf
    stdenv.cc.cc.lib
  ];
  sourceRoot = ".";
  unpackPhase =
    if darwin then
      ''
        runHook preUnpack
        tar -xzf "$src"
        runHook postUnpack
      ''
    else
      ''
        runHook preUnpack
        dpkg-deb -x "$src" .
        runHook postUnpack
      '';
  dontConfigure = true;
  dontBuild = true;
  # Preserve the upstream app bundle on macOS; Linux needs ELF patching and GTK wrappers.
  dontFixup = darwin;
  installPhase =
    if darwin then
      ''
        runHook preInstall
        mkdir -p "$out/Applications" "$out/bin"
        cp -R Kueri.app "$out/Applications/"
        ln -s "$out/Applications/Kueri.app/Contents/MacOS/kueri" "$out/bin/kueri"
        runHook postInstall
      ''
    else
      ''
        runHook preInstall
        mkdir -p "$out"
        cp -R usr/bin usr/share "$out/"
        substituteInPlace "$out/share/applications/Kueri.desktop" \
          --replace-fail 'Exec=kueri' "Exec=$out/bin/kueri"
        runHook postInstall
      '';

  meta = {
    description = "Native PostgreSQL, MySQL and SQLite database client";
    homepage = "https://github.com/umarta/kueri";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "kueri";
    platforms = builtins.attrNames assets;
  };
})
