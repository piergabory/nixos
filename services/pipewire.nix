{ pkgs, ... }:

{
  services.pipewire.enable = true;

  environment.systemPackages = with pkgs; [
    pwvucontrol # Audio controls GUI (GNOME)
  ];
}
