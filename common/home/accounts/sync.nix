{ config, lib, ... }:

{
  config = lib.mkIf (config.home.username == "piergabory") {
    programs.vdirsyncer.enable = true;

    services.vdirsyncer = {
      enable = true;
      frequency = "*:0/15";
    };

    programs.khal = {
      enable = true;
      locale = {
        firstweekday = 0;
        unicode_symbols = true;
      };
    };

    programs.khard.enable = true;
  };
}
