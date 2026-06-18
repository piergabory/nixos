{ config }:

{
  type = "monitor";
  title = "Local services";
  cache = "1m";
  sites = [
    {
      title = "Immich";
      url = "https://immich.piergabory.net";
      check-url = "http://${config.services.immich.host}:${toString config.services.immich.port}";
      icon = "si:immich";
    }
    {
      title = "Home Assistant";
      url = "https://home.piergabory.net";
      check-url = "http://127.0.0.1:8123";
      icon = "si:homeassistant";
    }
    {
      title = "Actual Budget";
      url = "https://budget.piergabory.net";
      check-url = "http://127.0.0.1:3000/health";
      icon = "si:actualbudget";
    }
    {
      title = "Jellyfin";
      url = "https://jelly.piergabory.net";
      check-url = "http://127.0.0.1:8096";
      icon = "si:jellyfin";
    }
    {
      title = "Mastodon";
      url = "https://masto.piergabory.net";
      check-url = "https://masto.piergabory.net/api/v2/instance";
      icon = "si:mastodon";
    }
    {
      title = "piergabory.net";
      url = "https://piergabory.net";
      icon = "si:nginx";
    }
    {
      title = "Pi-hole";
      url = "https://pihole.piergabory.net";
      check-url = "http://127.0.0.1:8080";
      icon = "si:pihole";
    }
    {
      title = "Syncthing";
      url = "https://sync.piergabory.net";
      check-url = "http://${config.services.syncthing.guiAddress}";
      icon = "si:syncthing";
      alt-status-codes = [ 401 ];
    }
    {
      title = "Vaultwarden";
      url = "https://vault.piergabory.net";
      check-url = "http://${config.services.vaultwarden.config.ROCKET_ADDRESS}:${toString config.services.vaultwarden.config.ROCKET_PORT}";
      icon = "si:vaultwarden";
    }
    {
      title = "Radicale";
      url = "https://dav.piergabory.net";
      check-url = "http://127.0.0.1:5232";
      icon = "mdi:calendar-sync";
      alt-status-codes = [ 401 ];
    }
  ];
}
