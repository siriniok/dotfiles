{ lib, pkgs, ... }:
let
  # Google's Linux platform-tools archive contains x86 binaries; keep ARM Linux
  # usable without installing an SDK containing executables for the wrong CPU.
  supported = pkgs.stdenv.hostPlatform.isDarwin || pkgs.stdenv.hostPlatform.isx86_64;
  android = (pkgs.androidenv.override { licenseAccepted = true; }).composeAndroidPackages {
    # "latest" resolves against repo.json in the locked nixpkgs input.
    cmdLineToolsVersion = "latest";
    platformToolsVersion = "latest";
    toolsVersion = null;
    buildToolsVersions = [ ];
    platformVersions = [ ];
    includeCmake = false;
    includeEmulator = false;
    includeSystemImages = false;
    includeSources = false;
    includeNDK = false;
  };
  sdk = android.androidsdk;
in
lib.mkIf supported {
  home.packages = [ sdk ];
  home.sessionVariables = {
    ANDROID_HOME = "${sdk}/libexec/android-sdk";
    ANDROID_SDK_ROOT = "${sdk}/libexec/android-sdk"; # Compatibility with older tools.
  };
}
