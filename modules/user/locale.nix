{ config, lib, isDarwin, ... }:
with lib;

let
  cfg = config.mainUser;
in {
  options.mainUser.keyboardLayout = mkOption {
    type = types.str;
    default = "fr";
  };

  config = mkMerge [
    {
      time.timeZone = mkDefault "Europe/Paris";
    }

    (optionalAttrs (!isDarwin) {
      i18n = {
        defaultLocale = "en_US.UTF-8";

        extraLocaleSettings = {
          LC_ADDRESS = "fr_FR.UTF-8";
          LC_IDENTIFICATION = "fr_FR.UTF-8";
          LC_MEASUREMENT = "fr_FR.UTF-8";
          LC_MONETARY = "fr_FR.UTF-8";
          LC_NAME = "fr_FR.UTF-8";
          LC_NUMERIC = "fr_FR.UTF-8";
          LC_PAPER = "fr_FR.UTF-8";
          LC_TELEPHONE = "fr_FR.UTF-8";
          LC_TIME = "fr_FR.UTF-8";
        };
      };

      console.keyMap = mkDefault cfg.keyboardLayout;
      services.xserver.xkb.layout = mkDefault cfg.keyboardLayout;
    })
  ];
}
