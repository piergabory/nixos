{ pkgs, lib, ... }:

{
  programs.btop.package = lib.mkForce pkgs.btop-cuda;

  programs.niri.settings = {
    input.keyboard.xkb.variant = "mac";

    debug.render-drm-device = "/dev/dri/by-path/pci-0000:01:00.0-render";

    spawn-at-startup = lib.mkAfter [
      { sh = "swaybg --image /etc/nixos/assets/house.jpg"; }
    ];

    outputs = {
      "DP-3" = {
        mode = {
          width = 3840;
          height = 2160;
          # refresh = 30.0;
        };
        scale = 1.5;
        position = {
          x = 0;
          y = 0;
        };
      };

      "DP-2" = {
        mode = {
          width = 3840;
          height = 2160;
          # refresh = 30.0;
        };
        scale = 1.5;
        transform.rotation = 180;
        position = {
          x = 0;
          y = -1440;
        };
      };
    };
  };
}
