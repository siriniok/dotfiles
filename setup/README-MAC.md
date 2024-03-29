# Setting up macOS Monterey 12.3.1

## Bootstrap

1. Run Safari and open https://github.com/siriniok/dotfiles/tree/master/setup/README-MAC.md (this file).
1. Set up Apple ID.
1. Set up profiles if needed.
1. Set up passwords and TouchID.
1. Copy system preferences manually from the old mac.
1. Run `curl --silent https://raw.githubusercontent.com/siriniok/dotfiles/master/setup/install.sh | bash`. _Save to a file and execute it. Otherwise run `chsh -s $(which zsh)` manually. Needs to be fixed_.
1. Reboot.

## Setting Up OS

1. Run Chrome and open https://github.com/siriniok/dotfiles/tree/master/setup/README.md (this file).
2. Login into Chrome. Don't forget to lock it to the launcher and unlock FF.
3. Open Chrome's settings and check "Use system title bar and borders".
4. Enable chrome://flags/#enable-scrollbars.
5. Run `~/.dotfiles/setup/setup-fresh-ubuntu.sh`.
6. Open Gnome Terminal profile preferences. Open Profile tab and click Edit.Rename the profile. Set custom font to Cousine for Powerline Regular 10,5 or 11.
7. Open System Settings. `Appearence > Set theme Radiance. Appearence > Behavior`. Enable "Auto-hide the Launcher" and workspaces.
8. Open System Settings. `Language Support > Regional Formats > English (United States) > Apply system-wide`.
9. Open System Settings. `Text Entry Settings > Change to Ctrl+Space / Ctrl+Shift+Space`. Add Ukrainian layout.

- `Keyboard Settings > Shorcuts`:
  - Launchers
    - Key to show the HUD = Super + Alt L.
    - Launch terminal = Ctrl+\`
    - Home folder = Super + E
  - Typing
    - Compose Key = Caps Lock
    - Alternative Characters Key = Right Alt

10. Open System Settings. Time and Date Settings. Set a city. On the Clock tab check Weekday, Date and month, 12-hour time, Seconds, Include week numbers.
11. Run `dconf write /org/gnome/desktop/wm/preferences/mouse-button-modifier '"<Super>"'` to change the default window movement key (Alt Left).
12. Unlock System Settings and Nautilus from the Launcher.
13. Open Software and Updates. On the Updates tab set all updates to displaying immediately.
14. Open Unity Tweak > Unity. Search tab. Uncheck Enable search for your files.
15. Open Unity Tweak > Window manager. Workspace Settings tab. Set 3x2 workspaces. Hotcorners tab. Set left bottom corner to Show workspaces, right upper to Toggle Desktop, right middle to Window Spread, and right bottom to Spread all Windows.
16. Open Unity Tweak > Appearence. Fonts tab. Set all font sizes to 10, enable Full Hinting.
17. Reboot.

## Setting Up Work Environment

1. Open Vim. Run `:PluginInstall`.
2. Open tmux. Press `C-a I` to install plugins.

## Updating Work Environment

1. Open Vim. Run `:PluginUpdate`.
2. Open tmux. Press `C-a U` to install plugins.
3. Run `upgrade_oh_my_zsh` on Terminal
4. Run `sudo apt-get update && sudo apt-get upgrade`
5. Run `sudo snap refresh`.
6. Open `~/.dotfiles`. Run `git pull && rake`.

# Setting Up OS X

1. Run `setup/bootstrap`.
1. Run `setup/generate-ssh`.
1. Run `setup/pm-install`.
1. Run `setup/setup-pg`.
1. Run `setup/vscode-plugins.sh`.
1. Run `setup/macos-config`.
1. Reboot.
