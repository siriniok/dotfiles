# Explicit system provisioning for Ubuntu and other non-NixOS systemd hosts.
{
  lib,
  writeShellApplication,
  writeText,
  coreutils,
  gawk,
  kmod,
  nix,
  keyd,
  dconf,
}:
let
  configFile = ../../modules/home/keyd/default.conf;
  quirksFile = ../../modules/home/keyd/libinput.quirks;
  keyboard = import ../../lib/gnome-keyboard.nix { inherit lib; };
  gdmKeyboard = writeText "gdm-keyboard.ini" (lib.generators.toDconfINI keyboard.settings);
  gdmLocks = writeText "gdm-keyboard-locks" (
    lib.concatMapStrings (
      path:
      lib.concatMapStrings (name: "/${path}/${name}\n") (builtins.attrNames keyboard.settings.${path})
    ) (builtins.attrNames keyboard.settings)
  );
  unit = writeText "dotfiles-keyd.service" ''
    [Unit]
    Description=keyd keyboard remapping daemon
    After=local-fs.target

    [Service]
    Type=simple
    ExecStart=/var/lib/dotfiles-keyd/package/bin/keyd
    ExecReload=/var/lib/dotfiles-keyd/package/bin/keyd reload
    Restart=on-failure
    RestartSec=1s

    [Install]
    WantedBy=multi-user.target
  '';
  modules = writeText "dotfiles-keyd-modules.conf" "uinput\n";
in
writeShellApplication {
  name = "keyd-setup";
  runtimeInputs = [
    coreutils
    gawk
    kmod
  ];
  text = ''
    dry_run=false
    case "''${1:-}" in
      --help|-h)
        echo 'Usage: keyd-setup [--dry-run]'
        echo 'Install pinned keyd and shared keyboard settings, including GDM when installed.'
        exit 0
        ;;
      --dry-run) dry_run=true; shift ;;
    esac
    if (( $# )); then echo 'keyd-setup: unexpected arguments' >&2; exit 2; fi
    if [[ $(uname -s) != Linux ]]; then echo 'keyd-setup: Linux is required' >&2; exit 1; fi
    if ! "$dry_run"; then
      if [[ -e /etc/NIXOS ]]; then
        echo 'keyd-setup: NixOS manages this service declaratively; use j run.' >&2
        exit 1
      fi
      if [[ ! -d /run/systemd/system ]]; then
        echo 'keyd-setup: a running systemd host is required' >&2
        exit 1
      fi
      if (( EUID != 0 )); then exec sudo -- "$(readlink -f "$0")"; fi
    fi

    run() {
      printf '  '; printf '%q ' "$@"; printf '\n'
      "$dry_run" || "$@"
    }
    backup() {
      if [[ ( -e $1 || -L $1 ) && ! -e $1.before-dotfiles && ! -L $1.before-dotfiles ]]; then
        run cp -a -- "$1" "$1.before-dotfiles"
      fi
    }

    run install -d -m 0755 /etc/keyd /etc/systemd/system /etc/modules-load.d /etc/libinput /var/lib/dotfiles-keyd
    # Keep the service's package alive after user-profile upgrades and Nix GC.
    run ${lib.getExe' nix "nix-store"} --add-root /var/lib/dotfiles-keyd/package --indirect --realise ${keyd}
    backup /etc/keyd/default.conf
    backup /etc/systemd/system/keyd.service
    backup /etc/libinput/local-overrides.quirks
    run install -m 0644 ${configFile} /etc/keyd/default.conf
    run install -m 0644 ${unit} /etc/systemd/system/keyd.service
    run install -m 0644 ${modules} /etc/modules-load.d/dotfiles-keyd.conf

    if "$dry_run"; then
      echo '  Merge the keyd block into /etc/libinput/local-overrides.quirks, preserving other sections.'
    else
      temporary=$(mktemp)
      trap 'rm -f "$temporary"' EXIT
      if [[ -f /etc/libinput/local-overrides.quirks ]]; then
        awk '
          $0 == "[Dotfiles keyd keyboard]" { skip = 1; next }
          /^\[/ { skip = 0 }
          !skip { print }
        ' /etc/libinput/local-overrides.quirks > "$temporary"
      fi
      cat ${quirksFile} >> "$temporary"
      install -m 0644 "$temporary" /etc/libinput/local-overrides.quirks
    fi

    # GDM uses its own dconf profile. Preserve Ubuntu's packaged file-db entries
    # and other admin databases rather than replacing the greeter's configuration.
    if "$dry_run" || [[ -f /etc/dconf/profile/gdm || -f /usr/share/dconf/profile/gdm || -d /etc/gdm3 || -d /etc/gdm ]]; then
      run install -d -m 0755 /etc/dconf/profile /etc/dconf/db/dotfiles-keyboard.d/locks
      backup /etc/dconf/profile/gdm
      run install -m 0644 ${gdmKeyboard} /etc/dconf/db/dotfiles-keyboard.d/10-keyboard
      run install -m 0644 ${gdmLocks} /etc/dconf/db/dotfiles-keyboard.d/locks/keyboard
      if "$dry_run"; then
        echo '  Merge system-db:dotfiles-keyboard into /etc/dconf/profile/gdm when GDM is installed.'
      else
        if [[ -f /etc/dconf/profile/gdm ]]; then
          source_profile=/etc/dconf/profile/gdm
        elif [[ -f /usr/share/dconf/profile/gdm ]]; then
          source_profile=/usr/share/dconf/profile/gdm
        else
          printf 'user-db:user\n' > "$temporary"
          for defaults in /var/lib/gdm3/greeter-dconf-defaults /usr/share/gdm/greeter-dconf-defaults /var/lib/gdm/greeter-dconf-defaults; do
            if [[ -f $defaults ]]; then
              printf 'file-db:%s\n' "$defaults" >> "$temporary"
              break
            fi
          done
          source_profile=$temporary
        fi
        profile_content=$(awk -f ${./gdm-profile.awk} "$source_profile")
        printf '%s\n' "$profile_content" > "$temporary"
        install -m 0644 "$temporary" /etc/dconf/profile/gdm
      fi
      # Compile only our database, leaving unrelated system databases untouched.
      run ${lib.getExe' dconf "dconf"} compile /etc/dconf/db/dotfiles-keyboard /etc/dconf/db/dotfiles-keyboard.d
      run chmod 0644 /etc/dconf/db/dotfiles-keyboard
      echo 'GDM keyboard settings apply to the next greeter session; GDM was not restarted.'
    fi

    run modprobe uinput
    run systemctl daemon-reload
    run systemctl enable keyd.service
    if "$dry_run"; then
      echo '  Reload keyd.service if active; otherwise start it.'
    elif systemctl is-active --quiet keyd.service; then
      run systemctl reload keyd.service
    else
      run systemctl start keyd.service
    fi
  '';
  meta = {
    description = "Install shared keyd and GDM keyboard settings on systemd Linux hosts";
    platforms = lib.platforms.linux;
  };
  passthru = {
    inherit gdmKeyboard gdmLocks;
  };
}
