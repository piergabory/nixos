{ ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelParams = [
      # Fixes issue with MacPro dual GPUs
      "pci=nocrs"
    ];

    # Fixes issue with MacPro hardware
    blacklistedKernelModules = [
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
