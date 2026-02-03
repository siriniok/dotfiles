# Keep the release package set, replacing selected Linux packages with fixed releases.
{ inputs }:
_final: prev:
if prev.stdenv.hostPlatform.isLinux then
  let
    security = import inputs.nixpkgs-security {
      system = prev.stdenv.hostPlatform.system;
      config.allowUnfreePredicate = prev.config.allowUnfreePredicate;
    };
  in
  {
    # Preserve the release integration while updating the printing daemon to the
    # upstream maintenance release containing the October security fixes.
    cups-security =
      assert prev.lib.assertMsg (
        prev.cups.version == "2.4.19" && builtins.length (prev.cups.patches or [ ]) == 4
      ) "Review or retire the CUPS security override: the release package or backports changed.";
      prev.cups.overrideAttrs (_old: {
        version = "2.4.20";
        src = prev.fetchurl {
          url = "https://github.com/OpenPrinting/cups/releases/download/v2.4.20/cups-2.4.20-source.tar.gz";
          hash = "sha256-q02c1/PlgGAJHSsklyIj1kAWdfEcSbZav09u8x3qIv8=";
        };
        # All four 2.4.19 backports are included/superseded upstream in 2.4.20.
        # The guard above prevents silently dropping newly added release patches.
        patches = [ ];
      });
    # Leaf applications can use their complete, internally consistent closure.
    # CVE-2026-53432/53433 and GIMP image-parser fixes.
    inherit (security)
      fzf
      gimp
      ;
    # FreeRDP is also linked into release-built applications. Rebuild its fixed
    # source against release libraries, rather than importing a newer glibc ABI.
    freerdp =
      assert prev.lib.assertMsg (
        prev.lib.versions.major prev.freerdp.version == prev.lib.versions.major security.freerdp.version
      ) "Review the FreeRDP security override before changing its library ABI.";
      prev.freerdp.overrideAttrs (_old: {
        version = security.freerdp.version;
        src = security.freerdp.src;
      });
    # Upgrade the office suite to a release containing the CVE-2026-4430 fix.
    inherit (security) libreoffice;
  }
else
  { }
