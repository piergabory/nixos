{ ... }:

{
  services.postfix = {
    enable = true;
    settings.main = {
      hostname = "mail.piergabory.net";
      domain = "piergabory.net";
    };
  };
}
