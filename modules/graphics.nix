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

  services.displayManager.ly = {
    enable = true;
  };
  
  # Electron to use wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
