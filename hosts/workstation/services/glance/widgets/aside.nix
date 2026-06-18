[
  {
    type = "weather";
    location = "Paris, France";
    units = "metric";
    hour-format = "24h";
  }
  {
    type = "calendar";
    first-day-of-week = "monday";
  }
  {
    type = "custom-api";
    title = "Time";
    cache = "1m";
    body-type = "string";
    skip-json-validation = true;
    template = builtins.readFile ../templates/time-progress.html;
  }
  {
    type = "markets";
    markets = [
      {
        symbol = "CW8.PA";
        name = "MSCI World";
      }
      {
        symbol = "EURUSD=X";
        name = "EUR/USD";
      }
      {
        symbol = "SPY";
        name = "S&P 500";
      }
    ];
  }
  {
    type = "bookmarks";
    groups = [
      {
        title = "Services";
        links = [
          {
            title = "Immich";
            url = "https://immich.piergabory.net";
            icon = "si:immich";
          }
          {
            title = "Home Assistant";
            url = "https://home.piergabory.net";
            icon = "si:homeassistant";
          }
          {
            title = "Actual Budget";
            url = "https://budget.piergabory.net";
            icon = "si:actualbudget";
          }
          {
            title = "Jellyfin";
            url = "https://jelly.piergabory.net";
            icon = "si:jellyfin";
          }
          {
            title = "Mastodon";
            url = "https://masto.piergabory.net";
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
            icon = "si:pihole";
          }
          {
            title = "Syncthing";
            url = "https://sync.piergabory.net";
            icon = "si:syncthing";
          }
          {
            title = "Vaultwarden";
            url = "https://vault.piergabory.net";
            icon = "si:vaultwarden";
          }
          {
            title = "Radicale";
            url = "https://dav.piergabory.net";
            icon = "mdi:calendar-sync";
          }
        ];
      }
    ];
  }
]
