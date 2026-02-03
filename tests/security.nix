# Test effective policy rather than grepping module source text.
{
  home,
  system,
  pkgs,
}:
assert builtins.all (name: name == "root") system.nix.settings.trusted-users;
assert system.nix.settings.require-sigs;
assert !system.nix.settings.accept-flake-config;
assert home.programs.ssh.settings."*".data.IdentityFile == [ "~/.ssh/id_ed25519" ];
assert !home.programs.ssh.settings."*".data.ForwardAgent;
assert home.programs.ssh.settings."*".data.HashKnownHosts;
assert home.programs.vscode.profiles.default.userSettings."telemetry.telemetryLevel" == "off";
assert home.programs.vscode.profiles.default.userSettings."security.workspace.trust.enabled";
if pkgs.stdenv.isLinux then
  assert pkgs.lib.versionAtLeast system.services.printing.package.version "2.4.20";
  assert pkgs.lib.versionAtLeast home.programs.fzf.package.version "0.73.1";
  assert builtins.any (
    package: pkgs.lib.getName package == "gimp" && pkgs.lib.versionAtLeast package.version "3.2.6"
  ) home.home.packages;
  assert builtins.any (
    package:
    pkgs.lib.hasPrefix "libreoffice" (pkgs.lib.getName package)
    && pkgs.lib.versionAtLeast package.version "26.2.3"
  ) home.home.packages;
  assert system.nix.settings.sandbox;
  assert system.networking.firewall.enable;
  assert !system.services.openssh.settings.PasswordAuthentication;
  assert !system.services.openssh.settings.KbdInteractiveAuthentication;
  assert system.services.openssh.settings.PermitRootLogin == "no";
  assert system.services.transmission.settings.rpc-bind-address == "127.0.0.1";
  assert !system.services.transmission.settings.port-forwarding-enabled;
  assert system.virtualisation.docker.rootless.enable;
  assert system.userAccess.dockerUsers == [ ];
  true
else
  assert system.networking.applicationFirewall.enable;
  assert system.networking.applicationFirewall.enableStealthMode;
  assert !system.networking.applicationFirewall.allowSignedApp;
  true
