# Public defaults must be replaceable without merging private hardware into them.
{ lib }:
let
  evaluate =
    extra:
    lib.evalModules {
      specialArgs.inputs.local-config = ../config.nix;
      modules = [ ../modules/flake/identity.nix ] ++ extra;
    };
  defaults = (evaluate [ ]).config;
  local =
    (evaluate [
      {
        me = {
          username = "test-user";
          fullname = "Test User";
        };
        machine.nixosHardware = {
          options.marker = lib.mkOption {
            type = lib.types.str;
            default = "local-hardware";
          };
        };
      }
    ]).config;
  hardware = lib.evalModules { modules = [ local.machine.nixosHardware ]; };
in
assert defaults.me.username != "";
assert defaults.me.fullname != "";
assert defaults.me.email == "";
assert defaults.me.sshKey == "";
assert local.me.username == "test-user";
assert local.me.fullname == "Test User";
assert hardware.config.marker == "local-hardware";
assert !(builtins.hasAttr "fileSystems" hardware.config);
true
