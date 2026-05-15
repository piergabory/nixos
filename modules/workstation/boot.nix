{ ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelParams = [
      "amdgpu.dc=1"
    ];

    kernel.sysctl."kernel.split_lock_mitigate" = 0;
  };
}
