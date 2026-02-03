{
  lib,
  self,
  system,
}:
let
  # Package-bearing paths used by this repository. Keep this list explicit: walking
  # every NixOS/HM option evaluates broken defaults in unrelated disabled modules.
  hostPackageRoots =
    prefix: cfg:
    let
      enabled = path: lib.attrByPath path false cfg;
      paths = [
        [
          "fonts"
          "packages"
        ]
        [
          "systemd"
          "packages"
        ]
        [
          "services"
          "udev"
          "packages"
        ]
        [
          "hardware"
          "firmware"
        ]
        [
          "boot"
          "extraModulePackages"
        ]
        [
          "boot"
          "kernelPackages"
          "kernel"
        ]
      ]
      ++
        lib.optionals
          (enabled [
            "hardware"
            "graphics"
            "enable"
          ])
          [
            [
              "hardware"
              "graphics"
              "extraPackages"
            ]
            [
              "hardware"
              "graphics"
              "extraPackages32"
            ]
          ]
      ++
        lib.optional
          (enabled [
            "services"
            "printing"
            "enable"
          ])
          [
            "services"
            "printing"
            "drivers"
          ]
      ++
        lib.optional
          (
            enabled [
              "services"
              "fprintd"
              "enable"
            ]
            && enabled [
              "services"
              "fprintd"
              "tod"
              "enable"
            ]
          )
          [
            "services"
            "fprintd"
            "tod"
            "driver"
          ]
      ++
        lib.optional
          (enabled [
            "services"
            "transmission"
            "enable"
          ])
          [
            "services"
            "transmission"
            "package"
          ]
      ++
        lib.optional
          (enabled [
            "virtualisation"
            "waydroid"
            "enable"
          ])
          [
            "virtualisation"
            "waydroid"
            "package"
          ]
      ++
        lib.optional
          (enabled [
            "networking"
            "networkmanager"
            "enable"
          ])
          [
            "networking"
            "networkmanager"
            "plugins"
          ];
    in
    map (path: {
      scope = "${prefix}/${lib.concatStringsSep "/" path}";
      packages = lib.toList (lib.attrByPath path [ ] cfg);
    }) paths;
  expandEnvironment =
    package:
    [ package ]
    ++ lib.optionals (package ? wrappedRuby && package ? gems && builtins.isList package.gems) (
      # ruby.withPackages exposes exactly the selected Ruby and gems here.
      builtins.filter lib.isDerivation (package.buildInputs or [ ])
    )
    ++ lib.optionals (package ? emacs && package ? explicitRequires) (
      [ package.emacs ] ++ builtins.filter lib.isDerivation package.explicitRequires
    );
  editorRoots =
    prefix: cfg:
    lib.optionals (cfg.programs.vscode.enable or false) (
      lib.mapAttrsToList (name: profile: {
        scope = "${prefix}/vscode/${name}";
        packages = profile.extensions;
      }) cfg.programs.vscode.profiles
    );
  person =
    value:
    if builtins.isString value then
      value
    else if builtins.isAttrs value then
      value.name or (value.github or (value.shortName or "unknown"))
    else
      "unknown";
  people = values: lib.concatStringsSep ", " (map person (lib.toList values));
  describe =
    scope: package:
    let
      meta = package.meta or { };
      licenses = lib.toList (meta.license or [ ]);
      flags = map (license: if builtins.isAttrs license then license.free or null else null) licenses;
      authors = builtins.filter (value: value != null && value != "") (
        lib.toList (meta.authors or (meta.author or [ ]))
      );
      maintainers = builtins.filter (value: value != null) (
        lib.toList (meta.maintainers or [ ]) ++ lib.toList (meta.teams or [ ])
      );
    in
    {
      inherit scope;
      inherit (package) name;
      group =
        if builtins.elem false flags then
          "unfree"
        else if flags != [ ] && builtins.all (flag: flag == true) flags then
          "free"
        else
          "unknown";
      license = lib.concatStringsSep ", " (
        map (
          license:
          if builtins.isString license then
            license
          else if builtins.isAttrs license then
            license.spdxId or (license.shortName or (license.fullName or "unknown"))
          else
            "unknown"
        ) licenses
      );
      author =
        if authors != [ ] then
          people authors
        else if maintainers != [ ] then
          "maint: ${people maintainers}"
        else
          "";
    };
  homes =
    prefix: configurations:
    lib.concatLists (
      lib.mapAttrsToList (
        name: home:
        [
          {
            scope = "${prefix}/${name}";
            packages = home.config.home.packages;
          }
        ]
        ++ editorRoots "${prefix}/${name}" home.config
      ) configurations
    );
  hosts =
    kind: configurations:
    lib.concatMap (
      name:
      let
        cfg = configurations.${name}.config;
      in
      lib.optionals (cfg.nixpkgs.hostPlatform.system == system) (
        [
          {
            scope = "${kind}/${name}/system";
            packages = cfg.environment.systemPackages or [ ];
          }
        ]
        ++ hostPackageRoots "${kind}/${name}" cfg
        ++ lib.concatLists (
          lib.mapAttrsToList (
            user: home:
            [
              {
                scope = "${kind}/${name}/home/${user}";
                packages = home.home.packages;
              }
            ]
            ++ editorRoots "${kind}/${name}/home/${user}" home
          ) (cfg.home-manager.users or { })
        )
        ++ lib.mapAttrsToList (user: settings: {
          scope = "${kind}/${name}/user/${user}";
          # Home Manager installs this generated container via users.users.packages.
          packages = builtins.filter (p: (p.name or "") != "home-manager-path") (settings.packages or [ ]);
        }) (cfg.users.users or { })
      )
    ) (builtins.attrNames configurations);
  roots =
    homes "home" (self.legacyPackages.${system}.homeConfigurations or { })
    ++ hosts "nixos" (self.nixosConfigurations or { })
    ++ hosts "darwin" (self.darwinConfigurations or { })
    ++ lib.mapAttrsToList (name: shell: {
      scope = "dev/${name}";
      packages = (shell.buildInputs or [ ]) ++ (shell.nativeBuildInputs or [ ]);
    }) (self.devShells.${system} or { })
    ++ lib.mapAttrsToList (name: package: {
      scope = "flake/${name}";
      packages = [ package ];
    }) (self.packages.${system} or { });
in
lib.concatMap (
  root:
  map (describe root.scope) (
    lib.concatMap expandEnvironment (builtins.filter lib.isDerivation root.packages)
  )
) roots
