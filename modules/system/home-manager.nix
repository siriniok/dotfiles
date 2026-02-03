# One bridge from system accounts to the shared user environment.
{
  config,
  flake,
  lib,
  ...
}:
{
  # The user's Home Manager configuration selects the login-shell package.
  users.users = lib.genAttrs config.myusers (
    name:
    let
      zsh = config.home-manager.users.${name}.programs.zsh;
    in
    {
      shell = lib.mkIf zsh.enable zsh.package;
    }
  );

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit flake; };
    users = lib.genAttrs config.myusers (name: {
      imports = [ (flake.inputs.self + /configurations/home/default.nix) ];
      home.username = name;
      home.homeDirectory = config.users.users.${name}.home;
    });
  };
}
