# Configuration reference

[← README](../README.md)

- [Module ownership](#module-ownership)
- [Optional applications and language tooling](#optional-applications-and-language-tooling)
- [User privileges](#user-privileges)
- [Local activation inputs](#local-activation-inputs)
- [Targeted security updates](#targeted-security-updates)

## Module ownership

| Path                                                      | Responsibility                                                                                |
| --------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| [config.nix](../config.nix)                               | Public name/nickname and overridable defaults                                                 |
| `config.local.nix`                                        | Ignored identity, generated hardware module and optional feature overrides                    |
| [configurations](../configurations)                       | Named NixOS, Darwin, and Home Manager profiles                                                |
| [modules/home](../modules/home)                           | Shared Home Manager settings and platform-specific modules                                    |
| [modules/nixos](../modules/nixos)                         | Linux system accounts, desktop services, networking, printing, security, containers, and keyd |
| [modules/system](../modules/system)                       | Nix policy, privilege options, and Home Manager integration shared by NixOS and Darwin        |
| [modules/darwin](../modules/darwin)                       | macOS system settings                                                                         |
| [modules/flake](../modules/flake)                         | Flake wiring, development shell, hooks, and checks                                            |
| [bin](../bin)                                             | Jaros and other command-line helpers                                                          |
| [tests](../tests)                                         | Deterministic regression checks                                                               |
| [.github/workflows](../.github/workflows)                 | CI, full builds, and weekly extension updates                                                 |
| [.github/actions/setup-nix](../.github/actions/setup-nix) | Pinned Nix installer and shared CI store cache                                                |

[modules/flake/default.nix](../modules/flake/default.nix) composes the flake modules:

| Module                                                    | Responsibility                                                       |
| --------------------------------------------------------- | -------------------------------------------------------------------- |
| [identity.nix](../modules/flake/identity.nix)             | Shared identity options and local overrides                          |
| [features.nix](../modules/flake/features.nix)             | Optional applications and language tooling across platforms          |
| [configurations.nix](../modules/flake/configurations.nix) | System and Home Manager profiles, shared context, and module exports |
| [packages.nix](../modules/flake/packages.nix)             | Local packages, package inventory, and formatter                     |
| [activate-home.nix](../modules/flake/activate-home.nix)   | Standalone Home Manager activation apps                              |
| [checks.nix](../modules/flake/checks.nix)                 | Regression checks and isolated test fixtures                         |
| [hooks.nix](../modules/flake/hooks.nix)                   | Git hook definitions                                                 |
| [devshell.nix](../modules/flake/devshell.nix)             | Development tools and shell setup                                    |

Register additional profiles in `configurations.nix`, packages in `packages.nix`,
and new flake modules in `modules/flake/default.nix`.

Host entry points select imports, platform, hostname, privileges, and their system
state version. Both system profiles read their hostname from `config.local.nix`.
The NixOS laptop keeps hand-written hardware policy in `hardware.nix` and generated
disk/device facts in local `machine.nixosHardware`. The tracked
`hardware-configuration.nix` is only a generic CI fixture. Home Manager's entry point owns
its username defaults, standalone package policy, and home state version.
System user creation and Home Manager initialization are shared through
[home-manager.nix](../modules/system/home-manager.nix). Shared privilege policy is in
[users.nix](../modules/system/users.nix); each platform owns its account creation.
Integrated Home Manager profiles use their system account's home directory.

Home Manager owns user programs, development tools, desktop applications, fonts,
GNOME preferences and shortcuts, Linux GPG agents, and dotfiles. Its
[default.nix](../modules/home/default.nix) imports features explicitly, with
platform-specific user settings under `modules/home/platforms` and GNOME session
settings under [modules/home/gnome](../modules/home/gnome). These user settings apply
with standalone Home Manager on Ubuntu as well as with integrated NixOS profiles.
NixOS retains privileged services, drivers, GNOME/GDM installation, 1Password
integration, and rootless Docker. Transmission uses a headless system daemon and a
Home Manager GTK client. Home Manager also owns macOS Dock/Finder preferences
through `targets.darwin.defaults`, including standalone installations. Darwin
owns account integration, Touch ID, and system keyboard mappings. The legacy `modules/home/setup`,
`modules/home/zsh`, and `modules/home/tilde` directories remain unchanged.

Home directories default to `/home/<username>` on Linux and `/Users/<username>`
on macOS. Linux desktop settings are isolated from Darwin settings. On macOS,
Home Manager installs the native Ghostty application using `pkgs.ghostty-bin`.
Neovim uses LazyVim via [modules/home/neovim](../modules/home/neovim). Nix-index and
comma are configured in [nix-index.nix](../modules/home/nix-index.nix). On Intel
macOS, which lacks a prebuilt index in the locked database input, run `nix-index`
once to create the local command index.

## Optional applications and language tooling

The temporarily disabled components have typed switches in
[features.nix](../modules/flake/features.nix). All four switches currently default
to `false`. Re-enable any of them in `config.local.nix` alongside `me`:

```nix
{
  features = {
    apps.gitbutler.enable = true;
    apps.microsoftEdge.enable = true;
    apps.androidStudio.enable = true;
    languages.haskell.enable = true;
  };
}
```

Each switch controls every relevant installation path. Android Studio selects
the Darwin cask or supported Linux package. Haskell selects the compiler,
language server, formatters, and integrations for all three editors together.
Apply local overrides with `j run`; CI uses the versioned defaults. Zoom remains
removed, and the Android command-line SDK is independent of the IDE switch.

Shared editor tools are resolved once in
[editor-tools.nix](../modules/home/editor-tools.nix), using the package selection in
[lib/editor-tools.nix](../lib/editor-tools.nix). Development shells and host profiles
retain their own package policy; editors reuse the Home Manager tool set.

## User privileges

System profiles manage the primary user from `me.username`. Add accounts through
`myusers`; administrator access and Nix trust are separate, explicit lists:

```nix
{ flake, ... }:
{
  userAccess = {
    administrators = [ flake.config.me.username ]; # NixOS wheel membership.
    dockerUsers = [ ]; # Rootful Docker access; unnecessary for rootless Docker.
    nixTrustedUsers = [ ]; # Keep root-equivalent daemon operations behind sudo.
  };
}
```

All lists default to empty and accept only managed users. Root remains trusted
by Nix; macOS administrator groups are managed separately. Rootful Docker group
membership and Nix trust grant root-equivalent powers. See
[users.nix](../modules/system/users.nix) for the policy.
The NixOS laptop profile explicitly grants the primary user administrator access.
Neither host profile grants ordinary users Nix daemon trust; normal builds still
work. Untrusted flake cache settings will not be silently accepted.

## Local activation inputs

Activation commands load `config.local.nix` without `--impure` or lock-file
changes. Plain flake checks use the shared name/nickname, hostname `nixos`,
empty email/key, and a label-based filesystem fixture. These defaults
are for evaluation, not deployment to an existing machine. To evaluate with local settings, add:

```text
--no-write-lock-file --override-input local-config "path:$PWD/config.local.nix"
```

`nix run` and `nix run .#activate` activate the standalone Home Manager profile.
They use shared defaults unless you pass the local input override above. Use
Jaros or the installer for NixOS and Darwin system activation.

## Targeted security updates

The host stays on the release Nixpkgs input. On Linux,
[security-overlay.nix](../lib/security-overlay.nix) selects newer leaf applications
from the separately locked `nixpkgs-security` input. NixOS selects a pinned CUPS
maintenance release for the printing daemon while retaining release client libraries.
FreeRDP's fixed source is rebuilt against release dependencies to preserve
library compatibility. The same overlay applies to NixOS and standalone
Home Manager; Darwin keeps its supported release packages.

`j update` updates both inputs. Review the overlay when upstream release packages
catch up so temporary replacements can be retired. Shared multimedia libraries
stay on the release package set: changing FFmpeg major versions or mixing glibc
ABIs requires a coordinated consumer update. Package version floors are checked by
[security.nix](../tests/security.nix).
