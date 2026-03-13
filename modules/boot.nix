{ config, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.12.74"
  ];

  boot = {
    extraModulePackages = with config.boot.kernelPackages; [ broadcom_sta ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelParams = [
      "pci=nocrs"
    ];

    # Disable other conflicting drivers
    blacklistedKernelModules = [
      # Disable wifi
      "wl"
      "b43"
      "bcma"
      "ssb"
      "brcmsmac"
      "brcmfmac"
      "cfg80211"
      "mac80211"

      "apple_gmux" # silence gmux warning, Shouldn't be needed on Mac Pro 2013
    ];
  };
}
