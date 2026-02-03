{ flake, ... }:
{
  sops.age = {
    keyFile = "/etc/sops/age/keys.txt";
    generateKey = true;
  };
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
    };
  };
  security.auditd.enable = true;
  security.audit.enable = true;

  # Privileged 1Password wrappers and Polkit rules belong to the system.
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ flake.config.me.username ];
  };
}
