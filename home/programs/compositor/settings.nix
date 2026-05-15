{ ... }:

{
  programs.niri.settings = {
    debug = {
      render-drm-device = "/dev/dri/by-path/pci-0000:01:00.0-render";
    };

    hotkey-overlay.skip-at-startup = true;
    prefer-no-csd = true;

    animations.enable = false;
  };
}
