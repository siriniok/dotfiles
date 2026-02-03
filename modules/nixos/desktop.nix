# System desktop services; session preferences and fonts live in Home Manager.
# GNOME handles Wayland touchpad gestures itself; Touchégg handles X11 only.
{
  imports = [ ./gui ];
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
