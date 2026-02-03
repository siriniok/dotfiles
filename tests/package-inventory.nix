{ lib }:
let
  package = name: meta: {
    inherit name meta;
    type = "derivation";
  };
  free = package "free-1" {
    license = lib.licenses.mit;
    authors = [ "Upstream team" ];
  };
  mixed = package "mixed-1" {
    license = [
      lib.licenses.mit
      lib.licenses.unfree
    ];
  };
  maintained = package "maintained-1" {
    license = [
      lib.licenses.mit
      lib.licenses.bsd3
    ];
    maintainers = [ { name = "Package maintainer"; } ];
    teams = [ { shortName = "Packaging team"; } ];
  };
  unknown = package "unknown-1" { };
  legacy = package "legacy-1" { license = "MIT"; };
  driver = package "driver-1" { license = lib.licenses.unfree; };
  font = package "font-1" { license = lib.licenses.ofl; };
  kernel = package "kernel-1" { license = lib.licenses.gpl2Only; };
  rubyEnvironment = (package "ruby-with-packages" { }) // {
    wrappedRuby = true;
    gems = [ maintained ];
    buildInputs = [
      free
      maintained
    ];
  };
  emacsEnvironment = (package "emacs-with-packages" { }) // {
    emacs = free;
    explicitRequires = [ maintained ];
  };
  roots = import ../lib/package-inventory.nix {
    inherit lib;
    system = "test-system";
    self = {
      outPath = "/checkout";
      legacyPackages.test-system.homeConfigurations.default.config.home.packages = [
        free
        mixed
        maintained
        unknown
        legacy
        rubyEnvironment
        emacsEnvironment
      ];
      legacyPackages.test-system.homeConfigurations.default.config.programs.vscode = {
        enable = true;
        profiles.default.extensions = [ legacy ];
      };
      nixosConfigurations.host.config = {
        nixpkgs.hostPlatform.system = "test-system";
        fonts.packages = [ font ];
        boot.kernelPackages.kernel = kernel;
        services.fprintd = {
          enable = true;
          tod = {
            enable = true;
            inherit driver;
          };
        };
        environment.gnome.excludePackages = [ (package "excluded" { }) ];
        environment.systemPackages = [ free ];
        home-manager.users.person.home.packages = [ maintained ];
        users.users.person.packages = [
          unknown
          (package "home-manager-path" { })
        ];
      };
      nixosConfigurations.host.options = throw "Never inspect unrelated module defaults";
      darwinConfigurations.other.config = {
        nixpkgs.hostPlatform.system = "other-system";
        environment.systemPackages = throw "Must not evaluate packages for a different platform";
      };
      devShells.test-system.default.nativeBuildInputs = [ free ];
      packages.test-system.example = maintained;
    };
  };
  row = name: builtins.head (builtins.filter (p: p.name == name) roots);
in
assert (row "free-1").group == "free";
assert (row "mixed-1").group == "unfree";
assert (row "maintained-1").group == "free";
assert (row "unknown-1").group == "unknown";
assert (row "legacy-1").group == "unknown";
assert (row "free-1").author == "Upstream team";
assert (row "maintained-1").author == "maint: Package maintainer, Packaging team";
assert (row "maintained-1").license == "MIT, BSD-3-Clause";
assert (row "driver-1").group == "unfree";
assert (row "font-1").group == "free";
assert (row "kernel-1").group == "free";
assert (row "ruby-with-packages").group == "unknown";
assert builtins.length roots == 20;
assert !(builtins.any (p: p.name == "excluded" || p.name == "not-explicit") roots);
assert !(builtins.any (p: p.name == "home-manager-path") roots);
true
