# Desktop reference

[← README](../README.md)

- [Desktop reference](#desktop-reference)
  - [Ghostty sessions and keyboard controls](#ghostty-sessions-and-keyboard-controls)
  - [Desktop applications](#desktop-applications)
  - [SSH](#ssh)
  - [GNOME and Wayland](#gnome-and-wayland)
    - [Ubuntu and other systemd Linux hosts](#ubuntu-and-other-systemd-linux-hosts)
  - [Codex desktop notifications](#codex-desktop-notifications)

## Ghostty sessions and keyboard controls

[ghostty.nix](../modules/home/ghostty.nix) owns Ghostty's package and settings for
all platforms. After `j run`, reload Ghostty's configuration before testing.

On macOS, `window-save-state = always` restores windows, tabs, split layouts,
and working directories. Keep the layout open when quitting Ghostty with
`Cmd+Q`, then relaunch it. This recreates terminal windows with fresh shells;
it does not keep running programs alive. Shell integration is enabled to report
working directories. [Ghostty's restoration setting](https://ghostty.org/docs/config/reference#window-save-state)
has no effect on Linux: native Linux tab/split restoration is currently unavailable.

Ghostty uses a **Ctrl+A** prefix for tmux-style commands. Release the prefix,
then press the command key; each command returns control to the application.
These bindings use Ghostty directly and do not require tmux.

| Keys             | Action                                   |
| ---------------- | ---------------------------------------- |
| `c`              | New tab                                  |
| `p` / `n`        | Previous / next tab                      |
| `\|` / `-`       | Split right / down                       |
| Arrow keys       | Focus the split in that direction        |
| `z`              | Toggle split zoom                        |
| `[`              | Enter Emacs-style scrollback mode        |
| `]`              | Paste the system clipboard               |
| `Ctrl+A`         | Send a literal Ctrl+A to the application |
| `Esc` / `Ctrl+G` | Cancel the prefix                        |

In scrollback mode, use the following keys without repeating the prefix:

| Keys                    | Action                                               |
| ----------------------- | ---------------------------------------------------- |
| `Ctrl+P` / `Ctrl+N`     | Scroll up / down one line                            |
| `Alt+V` / `Ctrl+V`      | Scroll up / down one page                            |
| `Alt+<` / `Alt+>`       | Start / end of scrollback                            |
| `Ctrl+S`                | Open search and leave scrollback mode                |
| `Alt+W`                 | Copy an existing selection and leave scrollback mode |
| `Esc`, `q`, or `Ctrl+G` | Leave scrollback mode                                |

An unknown prefix command sends the prefix and that key to the application;
use `Esc` or `Ctrl+G` to cancel explicitly. Unbound keys are ignored while
scrollback mode is active. Scrollback mode is not a keyboard text-selection
cursor. Ordinary Ghostty shortcuts remain available outside scrollback mode.

Zsh also uses Vim editing: start typing in insert mode, press `Esc` for command
mode, use motions such as `h`, `l`, `w`, `b`, and `0`, then `i` or `a` to resume
typing. Zsh's `Esc` handling is independent of Ghostty's navigation table.
Open a new shell after activation to load the new Zsh keymap.

## Desktop applications

[desktop-apps.nix](../modules/home/desktop-apps.nix) installs 1Password, Google
Chrome, Postman, Spotify, Firefox, and LocalSend. Microsoft Edge, GitButler, and
Android Studio are disabled by their feature switches. GIMP and VLC
use Nix on Linux and Homebrew on macOS, managed by the Darwin system
profile. VS Code and its extensions remain managed by
[vscode.nix](../modules/home/vscode.nix). Apply changes with `j run`.

On macOS, Nix-managed applications appear under `~/Applications/Home Manager Apps`.
Standalone Home Manager does not manage Homebrew; install GIMP and VLC there
with `brew install --cask gimp vlc`. The Darwin system profile installs these
casks automatically.

The Darwin system profile also installs Clipy, coconutBattery, The Unarchiver,
iTerm2, QLMarkdown, Syntax Highlight, QuickLook Video, Suspicious
Package, Dash, GitUp (`gitup-app`), Figma, Google Drive, VimR, GIMP,
and VLC through
Homebrew casks declared in [desktop.nix](../modules/darwin/desktop.nix). Install
[Homebrew](https://brew.sh/) once before applying the Darwin profile with `j run`;
nix-darwin manages the casks but does not bootstrap Homebrew. These apps install
under `/Applications`. Launch Syntax Highlight once to register its Quick Look
extension. The cask list applies to the Darwin system profile, not standalone
Home Manager.

On NixOS, the system module retains 1Password's privileged integration and
Home Manager avoids installing a second copy. Other apps belong to Home Manager.
Chrome, Edge, and Spotify are unavailable on ARM Linux in the locked nixpkgs and
are excluded there. The shared [unfree allowlist](../lib/unfree-predicate.nix) applies to
NixOS, nix-darwin, and standalone Home Manager.

Additional tools use the following package owners, without duplicating the
Darwin casks in Home Manager:

| Applications                                 | Linux                                                         | macOS                                  |
| -------------------------------------------- | ------------------------------------------------------------- | -------------------------------------- |
| Google Cloud SDK (`gcloud`), ngrok, Rainfrog | Shared Home Manager                                           | Shared Home Manager                    |
| Inkscape, Zotero, Beekeeper Studio           | Shared Home Manager                                           | Shared Home Manager                    |
| GitButler (temporarily disabled)             | Home Manager feature switch                                   | Home Manager feature switch            |
| Android Studio (temporarily disabled)        | Home Manager on x86_64; unavailable on ARM                    | Darwin cask                            |
| Figma                                        | Community-maintained `figma-linux` client                     | Official Darwin cask                   |
| Google Drive                                 | Launcher for the web interface; no official Linux sync client | Official Darwin cask                   |
| VimR                                         | macOS-only; use the configured Neovim                         | Darwin cask                            |
| Kueri                                        | Pinned binary on x86_64; upstream has no ARM Linux release    | Pinned app bundle through Home Manager |

[Kueri](https://github.com/umarta/kueri) is packaged locally in
[packages/kueri](../packages/kueri), with fixed release URLs and SHA-256 hashes.
Update its version, filenames, and hashes together when updating the application.
The package preserves the macOS bundle and patches Linux library paths for NixOS.
`nix build .#kueri` builds it on supported platforms. Leiningen, Rainfrog, and the
cloud CLIs are available through the shared Home Manager profile independently
of Darwin's Homebrew integration.

## SSH

[modules/home/ssh.nix](../modules/home/ssh.nix) manages `~/.ssh/config` for all
installation modes. Apply it with `j run`. If an unmanaged config already exists,
move it to `~/.ssh/config.local` first; Home Manager includes that file before
the shared defaults. Keep personal hostnames and per-host identities there.

Ed25519 is the default identity; there is no RSA fallback. Agent forwarding is
disabled and new known-host entries are hashed. Private keys and `known_hosts`
stay local. Key creation is interactive, outside Nix builds and activation. On a new
machine, create a passphrase-protected key (skip this if you already have one):

```sh
install -d -m 700 ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "your-email@example.com"
```

Register the contents of `~/.ssh/id_ed25519.pub` with your Git hosting provider.
The client adds keys to the agent when first used. Linux keeps the existing
Home Manager GPG agent with SSH support. macOS uses Apple's SSH client and
launchd agent; save the passphrase in Keychain once with:

```sh
/usr/bin/ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

The old `setup/generate-ssh.sh` and `tilde/.ssh/config` are replaced by this
configuration. No new agent is launched by a setup script.

NixOS accepts public-key SSH authentication only and prohibits direct root login.
Set `me.sshKey` to the **connecting machine's public Ed25519 key** to authorize
the primary user. An empty value adds no authorized key. Before switching a
remote machine, retain a working console/session and verify the new key from a
second connection. Home Manager manages the client only; Ubuntu/macOS server
authentication and firewall policy remain host responsibilities.

## GNOME and Wayland

The physical macOS-style translations are defined once in
[default.conf](../modules/home/keyd/default.conf), shared by NixOS and Ubuntu. In the table below, `Cmd` means either Super
key, `Option` means left Alt, and `Ctrl` means physical **Caps Lock** when keyd is
active. Without keyd, GNOME shortcuts use their ordinary logical modifiers;
hardware translations require the host's remapping service.

With keyd running, physical left Ctrl switches English/Ukrainian through XKB in
your GNOME session and in GDM, without the layout popup. Both NixOS and the Ubuntu
setup apply the shared keyboard definition to the greeter. Shift+left Ctrl also toggles layouts. Right
Alt is AltGr for third-level characters; add Shift for the fourth level. Right
Ctrl is Compose: for example, Compose, `'`, `e` produces `é` in the English layout.

| Physical shortcut                  | GNOME action                                    |
| ---------------------------------- | ----------------------------------------------- |
| Cmd+Space / Ctrl+Up                | Overview and search                             |
| Cmd+E                              | Open Ghostty                                    |
| Cmd+Enter                          | Open Files at the home directory                |
| Ctrl+Down                          | Application grid                                |
| Cmd+Tab / Cmd+Shift+Tab            | Next/previous application                       |
| Cmd+grave / Cmd+Shift+grave        | Next/previous window of the current application |
| Cmd+F3 / Cmd+Option+D              | Show or restore the desktop                     |
| Cmd+M / Cmd+H                      | Minimize the focused window                     |
| Ctrl+Cmd+Q                         | Lock the screen                                 |
| Ctrl+Cmd+F                         | Toggle fullscreen                               |
| Ctrl+Left / Ctrl+Right             | Previous/next workspace                         |
| Ctrl+Shift+Left / Ctrl+Shift+Right | Move the window between workspaces              |
| Cmd+Shift+3                        | Full-screen screenshot                          |
| Cmd+Shift+4 / Cmd+Shift+5          | Screenshot/recording selector                   |
| Cmd+Option+Escape                  | Open System Monitor                             |

On macOS, Home Manager runs `skhd` for the same launch shortcuts: `Cmd+E` opens
Ghostty and `Cmd+Enter` opens the home directory in Finder. Grant `skhd` access
in System Settings → Privacy & Security → Accessibility when first setting it
up. These are global shortcuts, including when another application is focused.
On Ubuntu with keyd, run `j setup-keyd` after applying Home Manager to update the
physical Command-key mappings as well.

On NixOS, activation reloads changed keyd mappings. To reload the installed mappings
manually without ending your session:

```sh
sudo systemctl reload keyd.service
```

### Ubuntu and other systemd Linux hosts

Apply the Home Manager profile to install GNOME settings and the shared keyboard
configuration, then provision the privileged input service explicitly:

```sh
j run
j setup-keyd --dry-run
j setup-keyd
```

The setup command requests sudo, installs the keyd version pinned by `flake.lock`,
copies the shared mappings to `/etc/keyd/default.conf`, and enables its systemd
service. It loads `uinput` and merges the virtual-keyboard libinput quirk while
preserving unrelated sections. Existing configuration and service files are
backed up once with a `.before-dotfiles` suffix. A root-owned Nix GC root keeps
the daemon package available independently of user-profile cleanup.

When GDM is installed, setup also merges its dconf profile and compiles a dedicated
keyboard database from [gnome-keyboard.nix](../lib/gnome-keyboard.nix). It preserves
Ubuntu's vendor defaults and other administrator databases. Only the keyboard
keys are locked to the shared values, including English/Ukrainian layouts, AltGr,
Compose, and direct layout switching. GDM is never stopped or restarted; the
greeter settings apply when GDM next starts its greeter, such as after a normal
reboot.

Run `j setup-keyd` again after changing the mappings or updating the pinned
package. It reloads an active service and starts it if inactive. Normal Home
Manager activation does not run sudo. For libinput's keyboard classification to
refresh in an existing desktop session, log out and back in when convenient.
NixOS continues to manage the service through `j run`.

## Codex desktop notifications

On Linux, Home Manager installs `codex-notify` and manages `~/.codex/hooks.json`.
Approval notifications offer **Approve once**, **Deny**, and **Full request…**.
The body contains the complete tool input, approval reason when supplied, and
working directory. GNOME may collapse long bodies; **Full request…** opens a
scrollable window with the same text and approval controls.

The hook waits up to two minutes for an explicit selection. Dismissal, timeout,
or missing desktop services return to Codex's normal prompt. Approval applies
only to the pending request. Question-tool notifications show the full input;
answer questions in VS Code.

After applying or changing hooks, review and trust them through `/hooks` in the
Codex CLI, then restart the Codex session. Notifications follow GNOME's settings,
including Do Not Disturb. See the [hook module](../modules/home/codex/default.nix)
and [official hook documentation](https://learn.chatgpt.com/docs/hooks).
