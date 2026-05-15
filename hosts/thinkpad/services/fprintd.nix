{ pkgs, ... }:

{
  services.fprintd = {
    enable = true;
    # tod = {
    #   enable = true;
    #   driver = pkgs.libfprint-2-tod1-vfs0090;
    # };
  };

  security.pam.services.ly.fprintAuth = true;
}
