# Vladyslav Siriniok's Dotfiles

Nix configurations for NixOS, macOS, and standalone Home Manager.

| Profile         | Platform                       | Manages                   |
| --------------- | ------------------------------ | ------------------------- |
| `nixos-laptop`  | x86_64 Linux                   | NixOS + Home Manager      |
| `darwin-laptop` | Apple Silicon macOS            | nix-darwin + Home Manager |
| `default`       | x86_64/aarch64 Linux and macOS | Standalone Home Manager   |

- [Vladyslav Siriniok's Dotfiles](#vladyslav-sirinioks-dotfiles)
  - [Installation](#installation)
    - [1. Prepare a checkout](#1-prepare-a-checkout)
    - [2. Configure the machine](#2-configure-the-machine)
    - [3. Activate](#3-activate)
  - [Daily use](#daily-use)
  - [Configuration](#configuration)
  - [Checks and CI](#checks-and-ci)
  - [Secrets](#secrets)
  - [Reference guides](#reference-guides)
  - [Tools](#tools)
  - [Resources \& Inspiration](#resources--inspiration)
    - [Dotfiles \& Nix](#dotfiles--nix)
    - [Shell Scripting](#shell-scripting)
    - [Text Editors](#text-editors)
  - [License](#license)

## Installation

### 1. Prepare a checkout

Cloning requires Git and either curl or wget. Activation requires
[Nix](https://nixos.org/download/), which NixOS already provides. Install
[Homebrew](https://brew.sh/) before applying the Darwin system profile's casks.

Download [install.sh](install.sh) from a reviewed commit, inspect it, then clone.
Obtain the commit SHA through a trusted channel:

```sh
revision='<reviewed-full-commit-SHA>'
curl --proto '=https' --proto-redir '=https' --tlsv1.2 -fsSL \
  "https://raw.githubusercontent.com/siriniok/dotfiles/$revision/install.sh" \
  -o install-dotfiles.sh
# Alternative download:
# wget --https-only -O install-dotfiles.sh \
#   "https://raw.githubusercontent.com/siriniok/dotfiles/$revision/install.sh"

less install-dotfiles.sh
bash install-dotfiles.sh --clone-only --ref "$revision"
cd ~/Work/dotfiles
```

The default destination is `~/Work/dotfiles`. Use `--directory PATH` for another
location and set the same absolute path as `me.dotfilesDirectory` below.
If an existing local configuration defines that path, the installer can read it
and clone directly there:

```sh
bash install-dotfiles.sh --config /path/to/config.local.nix --clone-only
```

Reading local configuration requires Nix. The installer looks beside the script,
then in the current directory; `--config` selects a file explicitly. It copies
that file into a new checkout with private permissions. A conflicting
`--directory` is rejected. Existing checkouts and destination configurations are
preserved; other destinations must be absent or empty.

Without `--ref`, a new checkout follows the mutable `nix` branch. With `--ref`, it
checks out the selected revision in detached HEAD state. Existing checkouts are
never pulled or reset; `--ref` applies only to new clones.

### 2. Configure the machine

Create **ignored** `config.local.nix` in the checkout. The public name and nickname
in [config.nix](config.nix) are overridable defaults:

```nix
{
  me = {
    username = "your-login-name";
    fullname = "Your Name";
    hostname = "my-machine";
    email = "me@example.com";
    sshKey = ""; # Optional: connecting machine's public Ed25519 key, never a private key.
    # dotfilesDirectory = "/absolute/path/to/dotfiles";
  };
}
```

Review the target profile before activation:

- **NixOS:** review [hardware.nix](configurations/nixos/nixos-laptop/hardware.nix)
  and embed your generated hardware module in the same local file as shown below.
  The tracked [hardware-configuration.nix](configurations/nixos/nixos-laptop/hardware-configuration.nix)
  is a CI fixture with an activation guard, not your machine's disk layout.
- **macOS:** review [darwin-laptop.nix](configurations/darwin/darwin-laptop.nix)
  and [Darwin modules](modules/darwin). The system profile targets Apple Silicon.
- **Standalone Home Manager:** use `--mode home` to manage the user environment.
  On Ubuntu, select extensions matching the host's GNOME version; see the
  [GNOME guide](docs/desktop.md#gnome-and-wayland).

For NixOS, add this beside `me` in `config.local.nix`:

```nix
machine.nixosHardware = { config, lib, modulesPath, ... }: {
  # Paste the body of /etc/nixos/hardware-configuration.nix here, including
  # imports, filesystems, swap and kernel modules. The host profile already
  # owns nixpkgs.hostPlatform.
};
```

Embed the module itself: the `local-config` input is a single file, so sibling
ignored imports are not automatically copied into the Nix store. These values
stay out of Git but enter the local store; keep credentials in [runtime secrets](#secrets).
Add new shared Nix source files to Git so the flake can see them.

### 3. Activate

Run as your normal login user:

```sh
./install.sh --dry-run
./install.sh
```

Automatic mode selects NixOS on NixOS, nix-darwin on macOS, and Home Manager on
other Linux hosts. Use `./install.sh --mode home` for standalone Home Manager on
any supported platform. System activation requests sudo and obtains rebuild
tools from the locked inputs; Janet and an existing nix-darwin installation are
not required. The script does not install Nix or update `flake.lock`.

| Option                             | Purpose                                        |
| ---------------------------------- | ---------------------------------------------- |
| `--mode auto\|home\|nixos\|darwin` | Select activation mode; default `auto`         |
| `--directory PATH`                 | Select the checkout destination                |
| `--config PATH`                    | Read/copy an existing local configuration      |
| `--ref REF`                        | Pin a new clone to a tag, branch, or commit    |
| `--clone-only`                     | Prepare a checkout without activation          |
| `--dry-run`                        | Preview commands without cloning or activating |

Omit `--clone-only` from a downloaded installer's invocation to continue directly
with activation once Nix and local configuration are available. Start a new login
shell afterward. GNOME extensions and input-source changes may need a new login
session; save your work before logging out.

## Daily use

Enter the checkout's development shell to use Jaros before activation:

```sh
nix develop
jaros help
```

After activation, the checkout's `bin` directory is on PATH and Zsh defines
`j` as an alias for `jaros`. Review [.envrc](.envrc) and run `direnv allow` for
automatic shell loading. If an old session cannot find Jaros, run `direnv reload`
or re-enter `nix develop`.

| Command                      | Purpose                                                                   |
| ---------------------------- | ------------------------------------------------------------------------- |
| `j --dry-run run`            | Preview activation                                                        |
| `j run`                      | Activate with `config.local.nix`                                          |
| `j update`                   | Update Nix inputs in `flake.lock`                                         |
| `j clean`                    | Collect unused store paths, then deduplicate files; preserves generations |
| `j packages`                 | List configured package roots by free/unfree/unknown license              |
| `j packages --all-platforms` | Include every exported platform                                           |
| `j lint`                     | Format Nix files                                                          |
| `j check`                    | Run flake checks                                                          |
| `j ci-check`                 | Run workflow lint, hooks, and flake checks                                |
| `j ci-home`                  | Build native standalone Home Manager profiles                             |
| `j ci-nixos` / `j ci-darwin` | Build the matching system without activation                              |
| `j ci-plan` / `j ci-local`   | Preview / run Linux Actions through act                                   |
| `j secrets-history`          | Scan available Git history for credentials, with redacted output          |
| `j setup-keyd`               | Provision keyd and GDM keyboard settings on Ubuntu/systemd Linux          |
| `j dev`                      | Enter the development shell                                               |

Commands run from their checkout. `jaros --dry-run COMMAND` previews subprocesses;
extra arguments are forwarded except for `run`, `clean`, `ci-check`, and `packages`,
which accepts only its documented flags. For standalone Home Manager on NixOS or
macOS, use `./install.sh --mode home` instead of `j run`.

The [package inventory](docs/development.md#package-inventory) reports configured
roots, licenses and maintainer/author metadata; it does not calculate dependency
closures or installed disk usage. VS Code extension pins update separately in a
weekly CI pull request.

## Configuration

| Location                                                          | Responsibility                                                     |
| ----------------------------------------------------------------- | ------------------------------------------------------------------ |
| [config.nix](config.nix) / `config.local.nix`                     | Public defaults / ignored identity, hardware and feature overrides |
| [configurations](configurations)                                  | Named host and standalone profiles                                 |
| [modules/home](modules/home)                                      | User applications, editors, shell, fonts and GNOME preferences     |
| [modules/nixos](modules/nixos) / [modules/darwin](modules/darwin) | Privileged services and platform integration                       |
| [modules/system](modules/system)                                  | Shared Nix policy, accounts policy and Home Manager integration    |
| [modules/flake](modules/flake)                                    | Constructors, packages, development shell, hooks and checks        |
| [bin/jaros.d](bin/jaros.d) / [tests](tests)                       | Janet command library and regression suites                        |

## Checks and CI

```sh
nix develop
jaros ci-check
jpm test
```

`ci-check` runs actionlint, pre-commit hooks and flake checks. Hooks enforce
nixfmt, Statix, Deadnix, ShellCheck, native Zsh syntax, zsh-lint and Gitleaks.
`nix develop` generates ignored `.pre-commit-config.yaml`; maintain definitions
in [hooks.nix](modules/flake/hooks.nix). `jpm test` runs the Janet Jaros and installer
suites without external Janet dependencies.

| Workflow                                                           | Trigger                   | Coverage                                                          |
| ------------------------------------------------------------------ | ------------------------- | ----------------------------------------------------------------- |
| [CI](.github/workflows/ci.yaml)                                    | Push, PR, manual          | Linux/macOS checks, Linux history scan, native profile evaluation |
| [Builds](.github/workflows/build.yaml)                             | Manual; Mondays 04:23 UTC | All four Home Manager platforms, NixOS and Apple Silicon Darwin   |
| [VS Code updates](.github/workflows/update-vscode-extensions.yaml) | Mondays 05:47 UTC         | Update extension pins, evaluate and open a PR                     |

CI builds never activate configurations. For local Actions, use `j ci-plan`, then
`j ci-local --dryrun` or `j ci-local`. NixOS provides rootless Docker; other hosts
need an accessible daemon. The [development guide](docs/development.md) covers
socket selection, runner limitations, tests and the weekly update workflow.

## Secrets

The repository integrates sops-nix with age. Keep passwords, tokens and private
keys out of ordinary Nix values and flake source files: they can enter the readable
Nix store. Reference decrypted files by their runtime paths and back up age keys
securely.

| Scope        | Age key                       |
| ------------ | ----------------------------- |
| Home Manager | `~/.config/sops/age/keys.txt` |
| NixOS system | `/etc/sops/age/keys.txt`      |

Both modules enable key generation when needed. For manual user-key creation on a
fresh machine, preserve any existing key and use private permissions:

```sh
install -d -m 700 ~/.config/sops/age
(umask 077; age-keygen -o ~/.config/sops/age/keys.txt)
```

Encrypt a file for that key's public recipient:

```sh
mkdir -p secrets
sops --age "$(age-keygen -y ~/.config/sops/age/keys.txt)" secrets/example.yaml
```

Declare the required `sops.secrets` entries in the relevant module; generating a
key alone does not configure any decrypted secrets. `secrets/` is ignored by
default. If a flake needs an encrypted file there, explicitly add only the
**encrypted** file to Git, or keep it in a separate private secrets source.
System secrets need a recipient corresponding to the system age key; do not
overwrite an existing system key with the user's key.

## Reference guides

| Guide                                  | Topics                                                                                                  |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| [Configuration](docs/configuration.md) | Module ownership, feature switches, user privileges and raw flake overrides                             |
| [Desktop](docs/desktop.md)             | GNOME/Wayland, keyboard shortcuts, Ubuntu keyd/GDM setup, Ghostty, apps, SSH, printing, macOS and fonts |
| [Editors](docs/editors.md)             | LazyVim, Helix/VS Code parity, language tooling, sessions, nested editors and Emacs                     |
| [Shell](docs/shell.md)                 | PATH, workspace, Zsh plugins, Git aliases, clipboard helpers and functions                              |
| [Development](docs/development.md)     | Checks, local Actions, package inventory, Janet commands/tests, runtimes and SDKs                       |

## Tools

| Utility                                          | Purpose                                                             |
| ------------------------------------------------ | ------------------------------------------------------------------- |
| `jaros` / `j`                                    | Activate configurations, update inputs, and run checks              |
| `rg` (ripgrep)                                   | Search file contents quickly                                        |
| `fd`                                             | Find files by name or pattern                                       |
| `sd`                                             | Find and replace text                                               |
| `bat`                                            | Read files with syntax highlighting and line numbers                |
| `fzf`                                            | Select files, history entries, or other input interactively         |
| `zoxide`                                         | Jump to frequently used directories with `z`                        |
| `jq`                                             | Filter, transform, and format JSON                                  |
| `tree`                                           | Display directory structure                                         |
| `tldr`                                           | Read concise command examples from tldr pages                       |
| `trash`                                          | Move files to the trash using Sindre Sorhus's trash-cli             |
| [ranger](https://github.com/ranger/ranger)       | Terminal file manager with Vim-style keybindings                    |
| [pgcli](https://www.pgcli.com/)                  | PostgreSQL CLI with completion and syntax highlighting              |
| `btop` / `htop`                                  | Inspect processes and system resource usage                         |
| `lazygit` / `lg`                                 | Browse and manage Git changes interactively                         |
| `delta`                                          | Read Git diffs with highlighting and side-by-side views             |
| `gh`                                             | Work with GitHub pull requests, issues, and Actions                 |
| `uv`                                             | Manage Python projects, environments, and command-line tools        |
| `direnv` + `nix-direnv`                          | Load and cache project development environments                     |
| `,` (comma)                                      | Run a command through Nix without installing it permanently         |
| `mtr`                                            | Diagnose network routes and packet loss                             |
| `openvpn`                                        | Connect using OpenVPN configuration files                           |
| `tailscale`                                      | Manage Tailscale connections                                        |
| `warp-cli`                                       | Manage Cloudflare WARP connections                                  |
| `moreutils`                                      | Shell helpers such as `sponge`, `ts`, and `vidir`                   |
| `age` / `sops`                                   | Encrypt files and manage encrypted secrets                          |
| `1Password` / `op`                               | Password manager application and CLI on all platforms               |
| `aws` (AWS CLI v2)                               | Manage AWS services                                                 |
| `clojure` / `clj`                                | Run Clojure programs and manage their dependencies                  |
| `java` / `javac`                                 | OpenJDK 25, also used by Clojure; Home Manager sets `JAVA_HOME`     |
| `ruby` / `gem` / `rake`                          | Run Ruby programs and Rake tasks                                    |
| `node` / `npm` / `npx`                           | Run Node.js programs and manage project dependencies                |
| `rustc` / `cargo` / `rustfmt` / `clippy`         | Build, format, and lint Rust projects                               |
| `rust-analyzer`                                  | Rust language server, with Nix-provided standard-library sources    |
| `sdkmanager` / `avdmanager` / `adb` / `fastboot` | Android command-line and platform tools                             |
| `eza`                                            | List files; replaces the old `exa` aliases                          |
| `dust`                                           | Inspect disk usage                                                  |
| `cloc`                                           | Count lines of code                                                 |
| `http` / `https` (HTTPie)                        | Make HTTP requests                                                  |
| `git-crypt` / `gpg`                              | Encrypt Git files and manage OpenPGP keys                           |
| `certbot`                                        | Request and renew TLS certificates                                  |
| `cowsay`                                         | Print messages with ASCII cows                                      |
| `catimg`                                         | Preview images directly in the terminal                             |
| `ouch`                                           | Create, extract, and list archives without format-specific commands |
| `lein`                                           | Build Clojure projects with Leiningen using the configured JDK      |
| `mc`                                             | Browse and manage files with Midnight Commander                     |
| `pstree`                                         | Display the process hierarchy                                       |
| `rlwrap`                                         | Add line editing and history to command-line programs               |
| `terraform`                                      | Manage infrastructure as code                                       |
| `tig`                                            | Browse Git history and changes in the terminal                      |
| `wget`                                           | Download files and mirror sites                                     |

The `trash` command is pinned in
[packages/trash-cli-sindresorhus](packages/trash-cli-sindresorhus), including
dependency integrity hashes. Use `trash FILE` to move a file to the trash.

## Resources & Inspiration

### Dotfiles & Nix

- [srid/nixos-config](https://github.com/srid/nixos-config) and
  [nixos-unified-template](https://github.com/juspay/nixos-unified-template): the
  configuration's starting point.
- [hlissner/dotfiles](https://github.com/hlissner/dotfiles/tree/master): inspiration
  for the Janet command interface.

### Shell Scripting

- [A Beginner’s Guide to the Best Command Line Tools](https://webdevstudios.com/2015/02/10/a-beginners-guide-to-the-best-command-line-tools/)
- [Hints for Writing Unix Tools](https://monkey.org/~marius/unix-tools-hints.html)

### Text Editors

- [Vim for Humans](https://vimebook.com/)
- [Practical Vim](https://pragprog.com/book/dnvim2/practical-vim-second-edition)
- [Modern Vim](https://pragprog.com/book/modvim/modern-vim)
- [Vim: revisited](http://mislav.net/2011/12/vim-revisited/)
- [Vim anti-patterns](https://sanctum.geek.nz/arabesque/vim-anti-patterns/)
- [Fugitive.vim - resolving merge conflicts with vimdiff](http://vimcasts.org/episodes/fugitive-vim-resolving-merge-conflicts-with-vimdiff/)

## License

[MIT](LICENSE) · Copyright 2015–2026 Vladyslav Siriniok.
