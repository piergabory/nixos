{ ... }:

{
  home.sessionVariables = {
    # Force Wayland on electron
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };
}
