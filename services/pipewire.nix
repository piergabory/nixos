{ pkgs, ... }:

{
  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    audio.enable = true;
    wireplumber.enable = true;
    pulse.enable = true;
  };

  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    pwvucontrol # Audio controls GUI (GNOME)
  ];
}
