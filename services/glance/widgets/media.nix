{ config, lib }:

let
  inherit (lib) customApi split;
  jellyfinHeaders = {
    X-Emby-Token._secret = config.age.secrets.jellyfin-api.path;
    Accept = "application/json";
  };
in

[
  (split [
    (customApi {
      title = "Jellyfin";
      title-url = "https://jelly.piergabory.net";
      cache = "10m";
      url = "http://127.0.0.1:8096/System/Info/Public";
      template = builtins.readFile ../templates/jellyfin.html;
    })
    (customApi {
      title = "Jellyfin Library";
      title-url = "https://jelly.piergabory.net";
      cache = "1h";
      url = "http://127.0.0.1:8096/Items/Counts";
      headers = jellyfinHeaders;
      template = builtins.readFile ../templates/jellyfin-library.html;
    })
  ])
]
