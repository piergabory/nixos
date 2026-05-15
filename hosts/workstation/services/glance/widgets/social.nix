{ lib }:

let
  inherit (lib) customApi split;
in

[
  (split [
    (customApi {
      title = "Minecraft";
      title-url = "https://mcsrvstat.us/server/piergabory.net:25565";
      cache = "1m";
      url = "https://api.mcsrvstat.us/3/piergabory.net:25565";
      template = builtins.readFile ../templates/minecraft.html;
    })
    (customApi {
      title = "Mastodon";
      title-url = "https://masto.piergabory.net";
      cache = "10m";
      url = "https://masto.piergabory.net/api/v2/instance";
      template = builtins.readFile ../templates/mastodon.html;
    })
  ])
  (split [
    (customApi {
      title = "Mastodon Trends";
      title-url = "https://masto.piergabory.net/explore/links";
      cache = "3h";
      url = "https://masto.piergabory.net/api/v1/trends/links";
      template = builtins.readFile ../templates/mastodon-trends.html;
    })
  ])
]
