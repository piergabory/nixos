{ lib, ... }:

{
  services.glance = {
    enable = true;
    openFirewall = true;
    settings = {
      server = {
        host = "127.0.0.1";
        port = 5678;
        proxied = true;
        assets-path = "/run/glance-assets";
      };

      theme = {
        background-color = lib.mkForce "0 0 16";
        primary-color = lib.mkForce "43 59 81";
        positive-color = lib.mkForce "61 66 44";
        negative-color = lib.mkForce "6 96 59";
        disable-picker = true;
      };
    };
  };
}
