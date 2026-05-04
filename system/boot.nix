{ ... }:

{
  boot = {
    # should not be referring to a disk like that,
    # won't prevent boot but this is not the right way to do it.
    resumeDevice = "/dev/nvme0n1p3";

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelModules = [
      "thinkpad_acpi" "intel_backlight"
    ];
  };
}
