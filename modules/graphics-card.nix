{ pkgs, config, ... }:

{
  environment.systemPackages = with pkgs; [
    coreutils-full
    pciutils
    usbutils
    sysstat
    smartmontools
  ];
   
  services.xserver.videoDrivers = [ "nvidia" ];

  boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };
  
  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
  };

  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text = ''
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
