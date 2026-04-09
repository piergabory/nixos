{ ... }:

{
  services.displayManager = {
    ly.enable = true;
    defaultSession = "niri";
  };

  security.pam.services.ly.fprintAuth = true;
}
