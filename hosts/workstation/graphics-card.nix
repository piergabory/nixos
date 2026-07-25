{ config, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];

  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  hardware = {
    graphics.enable = true;
    nvidia = {
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
    };
  };

  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text =
    ''
      {
        "rules": [
          {
            "pattern": {
              "feature": "procname",
              "matches": "niri"
            },
            "profile": "Limit Free Buffer Pool On Wayland Compositors"
          }
        ],
        "profiles": [
          {
            "name": "Limit Free Buffer Pool On Wayland Compositors",
            "settings": [
              {
                "key": "GLVidHeapReuseRatio",
                "value": 0
              }
            ]
          }
        ]
      }
    '';
}
