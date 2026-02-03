{ lib }:
pkg:
builtins.elem (lib.getName pkg) [
  "1password-gui"
  "1password"
  "1password-cli"
  "android-sdk-cmdline-tools"
  "android-sdk-platform-tools"
  "android-studio"
  "cloudflare-warp"
  "cmdline-tools"
  "firefox-bin"
  "firefox-bin-unwrapped"
  "google-chrome"
  "gitbutler"
  "intel-ocl"
  "libfprint-2-tod1-goodix"
  "microsoft-edge"
  "ngrok"
  "postman"
  "platform-tools"
  "spotify"
  "terraform" # Terraform formatting/validation in LazyVim (Business Source License).
  "vim-jack-in" # The locked nixpkgs classifies this plugin's license as unfree.
  "vscode"
  "winbox4"
]
|| lib.hasPrefix "vscode-extension-ms-vsliveshare-vsliveshare" (lib.getName pkg)
