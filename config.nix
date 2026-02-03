# Public name and nickname. Machine-specific fields come from the local-config input.
# Keep passwords, tokens, and private keys in runtime secrets (for example sops-nix).
{ lib, ... }:
{
  me = {
    username = lib.mkDefault "siriniok";
    fullname = lib.mkDefault "Vladyslav Siriniok";
  };
}
