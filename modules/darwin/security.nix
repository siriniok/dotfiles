{
  networking.applicationFirewall = {
    enable = true;
    enableStealthMode = true;
    blockAllIncoming = false; # Keep explicitly approved development services usable.
    allowSigned = true;
    allowSignedApp = false; # A vendor signature alone does not authorize a listener.
  };

  # Use Touch ID for local sudo, including commands run from Ghostty.
  security.pam.services.sudo_local.touchIdAuth = true;

  # Native installation supports communication between the app and `op`.
  programs._1password.enable = true;
  programs._1password-gui.enable = true;
}
