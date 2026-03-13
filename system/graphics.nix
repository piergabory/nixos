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
}
