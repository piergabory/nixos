{ config, lib, osConfig, ... }:

{
  config = lib.mkIf (config.home.username == "piergabory") {
    accounts.email.accounts.icloud = {
      primary = true;
      address = "piergabory@icloud.com";
      realName = "Pierre Gabory";
      userName = "piergabory@icloud.com";

      imap = {
        host = "imap.mail.me.com";
        port = 993;
      };

      smtp = {
        host = "smtp.mail.me.com";
        port = 587;
        tls.useStartTls = true;
      };

      passwordCommand = [ "cat" osConfig.age.secrets.icloud-mail.path ];
    };
  };
}
