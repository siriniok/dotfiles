# Steps after installing Ubuntu

1. Clean Unity Launcher. Leave only Terminal, Nautilus, Firefox and Settings.
2. Run `sudo apt-get upgrade` in terminal. Reboot.
3. Run FF and open https://github.com/siriniok/dotfiles/tree/master/setup/README.md (this file).
4. Run `curl --silent https://raw.githubusercontent.com/siriniok/dotfiles/master/setup/install.sh | sh`. *Save to a file and execute it. Otherwise run `chsh -s $(which zsh)` manually*.
5. Login out / login in or better reboot.
6. Run Chrome and login. Don't forget to lock it to the launcher and unlock FF.
7. Open Chrome's settings and check "Use system title bar and borders". Disable chrome://flags/#enable-color-correct-rendering.
8. Open Gnome Terminal profile preferences. Open Profile tab and click Edit. Rename the profile. Set custom font to Cousine for Powerline Regular 10,5. Check 'Run command as a login shell'. Select built-in scheme Solarized dark. Select Solarized palette. Set transparency to minimum. Restart the terminal.
9. Open System Settings. Appearence > Set theme Radiance. Appearence > Behavior > Enable "Auto-hide the Launcher" and workspaces.
10. Open System Settings. Language Support > Regional Formats > English (United States) > Apply system-wide.
11. Open System Settings. Text Entry Settings > Change to Ctrl+Space / Ctrl+Shift+Space. Add Ukrainian layout. Keyboard Settings > Shorcuts:
  - Launchers
    - Key to show the HUD = Super + Alt L.
    - Launch terminal = Ctrl+\`
    - Home folder = Super + E
  - Typing
    - Compose Key = Caps Lock
    - Alternative Characters Key = Right Alt
12. Open System Settings. Time and Date Settings. Set a city. On the Clock tab check Weekday, Date and month, 12-hour time, Seconds, Include week numbers.
13. Run `dconf write /org/gnome/desktop/wm/preferences/mouse-button-modifier  '"<Super>"'` to change the default window movement key (Alt Left).
14. Unlock System Settings and Nautilus from the Launcher.
15. Open Software and Updates. On the Other Software tab check Canonical Partners repository and remove the repeated Chrome repository. On the Updates tab set all updates to displaying immediately.
16. Open Unity Tweak > Unity. Launcher tab. Increase sensetivity. Search tab. Uncheck Enable search for your files.
17. Open Unity Tweak > Window manager. Workspace Settings tab. Set 3x2 workspaces. Hotcorners tab. Set left bottom corner to Show workspaces, right upper to Toggle Desktop, right middle to Window Spread, and right bottom to Spread all Windows.
18. Open Unity Tweak > Appearence. Fonts tab. Set all font sizes to 10, enable Full Hinting.
19. Reboot.

# Steps for setting up work environment

20. Open Vim. Run `:PluginInstall`.
21. Open tmux. Press `C-a I` to install plugins.
