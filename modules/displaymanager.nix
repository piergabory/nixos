{ pkgs, ... }:

{
  services.displayManager = {
    ly.enable = true;
    defaultSession = "niri";
  };
  
  console = {
    font = "ter=v32b";
    packages = [ pkgs.terminus_font ];
    earlySetup = true;
  };

  security.pam.services.ly.fprintAuth = true;
}
