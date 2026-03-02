{ ... }:

{
  programs.zen-browser = {
    enable = true;
    suppressXdgMigrationWarning = true;
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_WEBRENDER = "1";
    MOZ_X11_EGL = "1";
    MOZ_ACCELERATED = "1";
  };
}
