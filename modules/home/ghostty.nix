{ lib, pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    enableZshIntegration = true;
    settings = {
      font-size = 11;
      shell-integration = "detect";
      # Shell integration reports working directories for new/restored surfaces.
      window-inherit-working-directory = true;
      tab-inherit-working-directory = true;
      split-inherit-working-directory = true;

      # Native key sequences handle the prefix; Emacs-style scrollback stays modal.
      # Avoid a catch-all prefix table: pressing Shift for | must not cancel it.
      keybind = [
        "ctrl+a>ctrl+a=text:\\x01" # Press the prefix twice to send Ctrl+A to the app.
        "ctrl+a>c=new_tab" # Create a tab, like a tmux window.
        "ctrl+a>n=next_tab" # Select the next tab.
        "ctrl+a>p=previous_tab" # Select the previous tab.
        "ctrl+a>shift+backslash=new_split:right" # Prefix then | splits side by side.
        "ctrl+a>minus=new_split:down" # Prefix then - splits top and bottom.
        "ctrl+a>left=goto_split:left" # Focus the split to the left.
        "ctrl+a>down=goto_split:down" # Focus the split below.
        "ctrl+a>up=goto_split:up" # Focus the split above.
        "ctrl+a>right=goto_split:right" # Focus the split to the right.
        "ctrl+a>z=toggle_split_zoom" # Zoom the current split or restore the layout.
        "ctrl+a>left_bracket=activate_key_table:emacs" # Enter scrollback navigation.
        "ctrl+a>right_bracket=paste_from_clipboard" # Paste the system clipboard.
        "ctrl+a>escape=ignore" # Cancel the pending prefix command.
        "ctrl+a>ctrl+g=ignore" # Cancel the prefix with Emacs's quit key.
        "emacs/ctrl+p=scroll_page_lines:-1" # Scroll up one line.
        "emacs/ctrl+n=scroll_page_lines:1" # Scroll down one line.
        "emacs/alt+v=scroll_page_up" # Scroll up one page.
        "emacs/ctrl+v=scroll_page_down" # Scroll down one page.
        "emacs/alt+shift+comma=scroll_to_top" # Alt+< jumps to the start of scrollback.
        "emacs/alt+shift+period=scroll_to_bottom" # Alt+> jumps to live output.
        "emacs/ctrl+s=start_search" # Open scrollback search.
        "chain=deactivate_key_table" # Let the search field receive typed text.
        "emacs/alt+w=copy_to_clipboard" # Copy an existing selection.
        "chain=deactivate_key_table" # Resume the application after copying.
        "emacs/escape=deactivate_key_table" # Return to the running application.
        "emacs/q=deactivate_key_table" # Leave scrollback without closing anything.
        "emacs/ctrl+g=deactivate_key_table" # Cancel scrollback with Emacs's quit key.
        "emacs/catch_all=ignore" # Keep unbound scrollback keys out of the app.
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [
        "ctrl+shift+insert=paste_from_clipboard" # Clipboard Indicator's terminal paste action.
      ];
    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      # Native layout restoration is macOS-only; Linux currently has no equivalent.
      window-save-state = "always";
    };
  };
}
