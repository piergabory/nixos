{ lib, ... }:

{
  programs.niri.settings = {
    layout = {
      struts.top = lib.mkForce (-10);
      gaps = lib.mkForce 10;
    };
  };
}
