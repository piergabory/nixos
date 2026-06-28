{ config, lib, ... }:

{
  imports = [
    ./email.nix
    ./calendar.nix
    ./contacts.nix
    ./sync.nix
  ];

  config = lib.mkIf (config.home.username == "piergabory") {
    accounts.calendar.basePath = "${config.xdg.dataHome}/calendars";
    accounts.contact.basePath = "${config.xdg.dataHome}/contacts";
  };
}
