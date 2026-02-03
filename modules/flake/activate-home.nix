# Keep `nix run` available for standalone Home Manager without a deployment framework.
{
  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      home = config.legacyPackages.homeConfigurations.default;
      activate = pkgs.writeShellApplication {
        name = "activate-home";
        meta.description = "Activate the default standalone Home Manager profile";
        text = ''
          exec ${home.activationPackage}/activate "$@"
        '';
      };
    in
    {
      packages = {
        inherit activate;
        default = activate;
      };
      apps = {
        activate = {
          type = "app";
          program = lib.getExe activate;
          inherit (activate) meta;
        };
        default = config.apps.activate;
      };
    };
}
