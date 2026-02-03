# Regression checks and their isolated source fixtures.
{ config, inputs, ... }:
let
  inherit (config) features;
  systemConfigs = config.flake;
in
{
  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      handlerModule = import ../home/nix-index.nix {
        inherit pkgs;
        inherit (pkgs) lib;
        flake = { inherit inputs; };
        config.programs.nix-index.package = pkgs.nix-index;
      };
      handlerInit = pkgs.writeText "nix-index-handler-init.zsh" handlerModule.programs.zsh.initContent;
      testSource = pkgs.runCommand "regression-test-source" { } ''
        mkdir -p "$out/bin"
        cp ${../../bin/jaros} "$out/bin/jaros"
        cp ${../../bin/update-vscode-exts} "$out/bin/update-vscode-exts"
        cp ${../../bin/rfv} "$out/bin/rfv"
        cp -R ${../../bin/jaros.d} "$out/bin/jaros.d"
        cp -R ${../../tests} "$out/tests"
        cp ${../../install.sh} "$out/install.sh"
      '';
    in
    {
      checks.local-config =
        assert import ../../tests/local-config.nix { inherit lib; };
        pkgs.runCommand "local-config-privacy-regression" { } ''
          touch "$out"
        '';
      checks.security =
        assert import ../../tests/security.nix {
          home = config.legacyPackages.homeConfigurations.default.config;
          system =
            if pkgs.stdenv.isDarwin then
              systemConfigs.darwinConfigurations.darwin-laptop.config
            else
              systemConfigs.nixosConfigurations.nixos-laptop.config;
          inherit pkgs;
        };
        pkgs.runCommand "security-policy-regression" { } ''
          touch "$out"
        '';
      checks.rfv =
        pkgs.runCommand "rfv-security-regression"
          {
            nativeBuildInputs = [
              pkgs.janet
              pkgs.bash
            ];
          }
          ''
            janet ${testSource}/tests/test_rfv.janet ${testSource}/bin/rfv ${pkgs.janet}/bin/janet
            touch "$out"
          '';
      checks.keyd-setup = lib.mkIf pkgs.stdenv.isLinux (
        pkgs.runCommand "keyd-setup-regression"
          {
            nativeBuildInputs = [
              config.packages.keyd-setup
              pkgs.dconf
              pkgs.gawk
            ];
          }
          ''
            keyd-setup --help > help.txt
            keyd-setup --dry-run > plan.txt
            grep -F '/etc/keyd/default.conf' plan.txt
            grep -F '/var/lib/dotfiles-keyd/package' plan.txt
            grep -F 'systemctl enable keyd.service' plan.txt
            grep -F '/etc/dconf/db/dotfiles-keyboard' plan.txt
            if grep -E 'systemctl (stop|restart|try-restart) (gdm|display-manager)' ${config.packages.keyd-setup}/bin/keyd-setup; then
              echo 'Setup must not interrupt the graphical session' >&2
              exit 1
            fi

            # Preserve the Ubuntu vendor defaults and make profile merges repeatable.
            printf '%s\n' 'user-db:user' 'system-db:site' 'file-db:/var/lib/gdm3/greeter-dconf-defaults' > vendor.profile
            awk -f ${../../packages/keyd-setup/gdm-profile.awk} vendor.profile > merged.profile
            awk -f ${../../packages/keyd-setup/gdm-profile.awk} merged.profile > repeated.profile
            cmp merged.profile repeated.profile
            test "$(head -n 1 merged.profile)" = 'user-db:user'
            test "$(tail -n 1 merged.profile)" = 'system-db:dotfiles-keyboard'
            grep -Fx 'system-db:site' merged.profile
            grep -Fx 'file-db:/var/lib/gdm3/greeter-dconf-defaults' merged.profile

            # Read the compiled database as GDM would, without a running greeter.
            mkdir -p keyboard.d/locks
            cp ${config.packages.keyd-setup.gdmKeyboard} keyboard.d/10-keyboard
            cp ${config.packages.keyd-setup.gdmLocks} keyboard.d/locks/keyboard
            dconf compile keyboard.db keyboard.d
            mkdir -p vendor.d/locks
            printf "[org/gnome/desktop/input-sources]\nsources=[('xkb', 'de')]\n" > vendor.d/keyboard
            printf '/org/gnome/desktop/input-sources/sources\n' > vendor.d/locks/keyboard
            dconf compile vendor.db vendor.d
            printf 'user-db:user\nfile-db:%s/vendor.db\nfile-db:%s/keyboard.db\n' "$PWD" "$PWD" > read.profile
            export DCONF_PROFILE="$PWD/read.profile"
            export XDG_CONFIG_HOME="$PWD/user-config"
            export XDG_CACHE_HOME="$PWD/cache"
            mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"
            dconf read /org/gnome/desktop/input-sources/sources | grep -F 'us+altgr-intl'
            dconf read /org/gnome/desktop/input-sources/sources | grep -F "'ua'"
            dconf read /org/gnome/desktop/input-sources/xkb-options | grep -F 'grp:sclk_toggle'
            dconf read /org/gnome/desktop/input-sources/xkb-options | grep -F 'lv3:ralt_switch'
            dconf read /org/gnome/desktop/input-sources/xkb-options | grep -F 'compose:menu'
            grep -Fx '/org/gnome/desktop/input-sources/sources' keyboard.d/locks/keyboard
            if keyd-setup --unknown; then
              echo 'Unknown arguments must fail' >&2
              exit 1
            fi
            touch "$out"
          ''
      );
      checks.gnome-session =
        assert import ../../tests/gnome-session.nix {
          home = config.legacyPackages.homeConfigurations.default.config;
          system =
            if pkgs.stdenv.isLinux then systemConfigs.nixosConfigurations.nixos-laptop.config else null;
          inherit pkgs;
          inherit (pkgs) lib;
        };
        pkgs.runCommand "gnome-session-regression" { } ''
          touch "$out"
        '';
      checks.package-inventory =
        assert import ../../tests/package-inventory.nix { inherit (pkgs) lib; };
        pkgs.runCommand "package-inventory-regression" { } ''
          touch "$out"
        '';
      checks.optional-features =
        assert import ../../tests/optional-features.nix {
          home = config.legacyPackages.homeConfigurations.default.config;
          inherit features pkgs;
          inherit (pkgs) lib;
        };
        pkgs.runCommand "optional-features-regression" { } ''
          touch "$out"
        '';
      checks.codex-notify =
        pkgs.runCommand "codex-notify-regression" { nativeBuildInputs = [ pkgs.python3 ]; }
          ''
            python3 ${../../tests/test_codex_notify.py} ${../home/codex/notify.py}
            touch "$out"
          '';
      checks.install =
        pkgs.runCommand "install-script-regression"
          {
            nativeBuildInputs = [
              pkgs.janet
              pkgs.bash
            ];
          }
          ''
            janet ${testSource}/tests/test_install.janet ${testSource}/install.sh ${pkgs.janet}/bin/janet
            touch "$out"
          '';
      checks.jaros =
        pkgs.runCommand "jaros-cli-regression"
          {
            nativeBuildInputs = [
              pkgs.janet
              pkgs.jq
            ];
          }
          ''
            janet ${testSource}/tests/jaros.janet ${pkgs.janet}/bin/janet
            touch "$out"
          '';
      checks.nix-index-handler =
        pkgs.runCommand "nix-index-handler-regression"
          {
            nativeBuildInputs = [
              pkgs.janet
              pkgs.zsh
            ];
          }
          ''
            handler=$(awk '/^ *source / { print $2 }' ${handlerInit})
            janet ${testSource}/tests/test_nix_index.janet "$handler" ${pkgs.janet}/bin/janet
            touch "$out"
          '';
    };
}
