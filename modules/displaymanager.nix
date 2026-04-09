{ pkgs, ... }:

{
  services.displayManager = {
    ly.enable = true;
    defaultSession = "niri";
  };
  
  console = {
    font = "Lat2-Terminus16";
    packages = [ pkgs.terminus_font ];
    earlySetup = true;
  };

  security.pam.services.ly.fprintAuth = true;
}
