{ config, pkgs, ... }:
{
  programs.java = {
    enable = true;
    package = pkgs.jdk25;
  };

  # Shared defaults for NixOS, macOS, and standalone Home Manager.
  # flake.lock pins the exact versions within these release lines.
  home.packages = [
    (pkgs.ruby_4_0.withPackages (gems: [ gems.rake ]))
    pkgs.nodejs_26 # Includes npm.
    pkgs.python3 # Current default Python, shared by Linux and macOS.
    pkgs.rustc
    pkgs.cargo
    pkgs.rustfmt
    pkgs.clippy
    pkgs.rust-analyzer
    pkgs.stdenv.cc # Linker/compiler for Rust builds, including a fallback SDK on macOS.
    # Keep Clojure's launcher and the shell's JAVA_HOME on the same JDK.
    (pkgs.clojure.override { jdk = config.programs.java.package; })
    (pkgs.leiningen.override { jdk = config.programs.java.package; })
  ];

  home.sessionVariables.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
}
