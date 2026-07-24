{ config, lib, ... }:
with lib;
let
  cfg = config.accounts.icloud;
  mkDavAccountSync = import ./mkDavAccountSync.nix;
in
{
  options.accounts.icloud = {
    enable = mkEnableOption "Sync iCloud account data";
    appleId = mkOption {
      type = types.str;
    };
    realName = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      accounts = {
        email.accounts.icloud = {
          primary = true;
          address = cfg.appleId;
          realName = cfg.realName;
          userName = cfg.appleId;

          imap = {
            host = "imap.mail.me.com";
            port = 993;
          };

          smtp = {
            host = "smtp.mail.me.com";
            port = 587;
            tls.useStartTls = true;
          };

          passwordCommand = [
            "cat"
            config.age.secrets.icloud-mail.path
          ];
          thunderbird = {
            enable = true;
            profiles = [ "default" ];
          };
        };
      };
    }
    (mkDavAccountSync {
      label = "icloud";
      userName = cfg.appleId;
      passwordFile = config.age.secrets.icloud-dav.path;
      calurl = "https://caldav.icloud.com/";
      cardurl = "https://contacts.icloud.com/";
    })
  ]);
}
