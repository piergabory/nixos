{ ... }:

{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "security" = "user";
      };
      my_share_directory = {
        "valid users" = "piergabory";
      };
    };
  };
}
