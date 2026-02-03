{ pkgs, ... }:
{
  services.udev.packages = [ pkgs.yubikey-personalization ];

  # Enable touchpad support
  services.libinput.enable = true;

  hardware.graphics.extraPackages = with pkgs; [
    # UHD 620 uses the legacy runtime for Gen9 GPU compute support.
    intel-compute-runtime-legacy1
    intel-media-driver
  ];

  powerManagement.enable = true;
  services.power-profiles-daemon.enable = false;
  services.thermald.enable = true;
  services.auto-cpufreq.enable = true;
  services.logind.settings.Login.HandleLidSwitch = "hybrid-sleep";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "lock";
  services.logind.settings.Login.HandleLidSwitchDocked = "ignore";
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };
  # The Synaptics reader is supported by the standard libfprint drivers.
  services.fprintd.enable = true;

  # Bootloader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 20;
    };

    efi.canTouchEfiVariables = true;
  };
}
