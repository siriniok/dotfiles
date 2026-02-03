# Shell reference

[← README](../README.md)

- [Paths and workspace](#paths-and-workspace)
- [Git and shell environment](#git-and-shell-environment)
- [Zsh plugins](#zsh-plugins)

## Paths and workspace

Custom PATH entries have the same order on every platform: `~/.local/bin`,
`~/.bin`, `~/.cargo/bin`, `~/.docker/bin`, then the checkout's `bin` directory.
macOS also includes the selected Python version's `~/Library/Python/<version>/bin`;
Linux's Python user scripts already use `~/.local/bin`. System and Nix profile
paths remain managed by the host and Nix installer.

Home Manager creates `~/Work` on every platform and exports its path as `WORK`.
`CODE` and `C` point to `~/Work/code`.

## Git and shell environment

Git settings and global ignore patterns live in
[git.nix](../modules/home/git.nix). Home Manager generates
`~/.config/git/config` and `~/.config/git/ignore`; identity comes from the
shared/local Nix configuration. Delta remains the Git pager. The legacy
`.gitconfig` and `.gitignore_global` copies have been removed.

Zsh's environment is managed by [shell.nix](../modules/home/shell.nix), with
shared executable paths and `DOTFILES` in [path.nix](../modules/home/path.nix).
Home Manager generates `.zshenv`; native Zsh arrays deduplicate paths, and
`MANPATH` retains the system's default directories. There is no custom
`.zlogin`: Nix supplies Rust/Cargo, so no rustup environment script is sourced.
Python is supplied by `pkgs.python3` on every platform; the macOS user-script
path follows that package's Python version rather than a hardcoded release.

## Zsh plugins

Home Manager owns Zsh configuration, plugins, completion, and package selection.
Integrated system profiles derive each managed user's login shell from those
settings. NixOS provides the required system shell registration, with global
`compinit` disabled so Home Manager initializes completion once. Standalone Home
Manager configures Zsh without changing the host's account database.

Home Manager manages plugins in [shell.nix](../modules/home/shell.nix). Packaged
plugins follow the nixpkgs revision in `flake.lock`; use `pkgs.fetchFromGitHub`
with a fixed commit and hash for plugins absent from nixpkgs.

[git.nix](../modules/home/git.nix) loads the complete pinned Oh My Zsh
[Git aliases and helpers](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git)
on every platform, including `gst`, `gss`, `ga`, `gcmsg`, `gco`, `gcm`, `gl`,
and `gp`. Its current-branch helper supports named branches and detached HEADs.

```nix
{ pkgs, ... }:
{
  programs.zsh.plugins = [
    {
      name = "plugin-name";
      src = pkgs.plugin-package;
      file = "share/plugin-name/plugin-name.plugin.zsh";
    }
  ];
}
```

Completion-only plugins can use their function directory as `src`. The active
configuration loads zsh-completions before `compinit`; autosuggestions and syntax
highlighting use Home Manager's dedicated options. Apply changes, then run
`exec zsh`. The legacy `.zshrc` has been replaced by Home Manager's generated
configuration: shared 20,000-entry history, case-insensitive completion,
bracket/pattern highlighting, interactive comments, and overwrite protection
(`>!` explicitly replaces a file). Profile startup with
`ZPROF=1 zsh -i -c exit`. Optional `~/.zshlocal` and `~/.secret` are sourced at
runtime, after the managed configuration; keep credentials out of Nix values.
Starship owns the prompt; Oh My Zsh variables, theme, and wildcard imports are
not carried over. Legacy scripts under `modules/home/zsh` remain inactive.

Date helpers are native aliases: `isodate`, `isodate_utc`, `isodate_basic`,
`unixstamp`, and `date_locale`. Base64 helpers are `encode64` / `e64`,
`decode64` / `d64`, and `encodefile64` / `ef64` (writes `FILE.txt`). Encoding and
decoding accept stdin or one string argument and use the same Nix-provided
executable on Linux and macOS.

At an empty prompt, Ctrl+Z runs `fg` to resume a suspended job. With pending
input, it saves that input and clears the screen. This native widget works in
vi insert, vi command, and Emacs keymaps.

`xc` copies stdin and `xp` prints clipboard contents using macOS's `pbcopy` /
`pbpaste`, Wayland's `wl-copy` / `wl-paste`, or X11's `xclip`. Paste preserves
the copied data's trailing newlines. A headless shell reports that no graphical
clipboard is available. `myssh` copies `~/.ssh/id_ed25519.pub` using `xc`.
`password [BYTES]` generates, copies, and prints a password (default: 9 random
bytes), and `fm [PATH]` opens the platform's default file manager/application.

Quick Look (`ql`) and `coffee` are macOS-only. NetworkManager restart (`rntwrk`)
and the runtime inotify adjustment (`incinotify`) are Linux-only; persistent
NixOS limits belong in `boot.kernel.sysctl`. Scheduled shutdown cancellation and
local IPv4 discovery use each platform's native commands. The `ls` shortcuts
and `w30s` use Nix-provided tools consistently. The `ngrok3000` and `ngrok5000`
shortcuts use the installed ngrok CLI and require its account configuration.

The default pager is `less`, configured to
preserve ANSI colours, search without case sensitivity, avoid beeps, and exit
when the content fits one screen. FZF and Ctrl+T include hidden files while
excluding `.git`.

The pinned Oh My Zsh `macos` plugin is loaded on Darwin only, without loading
the framework. It provides helpers such as `ofd`, `cdf`, and `quick-look`.
`catimg FILE` previews an image using the standalone Nix package.

For archives, the standalone [ouch](https://github.com/ouch-org/ouch) package
replaces `universalarchive`; use its commands instead of `ua`:

```sh
ouch compress notes.txt images/ backup.tar.gz
ouch decompress backup.tar.gz
ouch list backup.tar.gz
```
