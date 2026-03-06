{ pkgs, ... }:

{
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        rocmPackages.clr.icd
      ];
    };

    amdgpu = {
      legacySupport.enable = true;
      initrd.enable = true;
    };

    firmware = [ pkgs.linux-firmware ];
  };

  services.xserver = {
    enable = true;
    excludePackages = with pkgs; [
      xterm
    ];
  };

  services.displayManager.ly = {
    enable = true;
  };

  security.pam.services = {
    ly.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;
    niri.enableGnomeKeyring = true;
  };
  # A polkit *agent* suitable for niri (Wayland):
  # polkit-gnome works fine even on non-GNOME if you just start the agent.
  environment.systemPackages = with pkgs; [
    polkit_gnome
    seahorse

    # opencl
    clinfo
  ];

  programs.xwayland.enable = true;

  # Electron to use wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
}
