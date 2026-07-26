{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cfg = config.modules.audio;
in
{
  options.modules.audio = {
    enable = mkEnableOption "Enable audio support";
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;

    services = {
      pulseaudio.enable = false;

      pipewire = {
        enable = true;
        audio.enable = true;
        wireplumber.enable = true;
        pulse.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      pwvucontrol # Audio controls GUI (GNOME)
    ];
  };
}
