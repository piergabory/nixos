let
  homelabDomain = "pierr.re";
  position = 200;
in
{
  programs.zen-browser.profiles.default.spaces.general.pins."Media" = {
    inherit position;
    id = "media_group";
    isFolderCollapsed = true;
    pins = {
      "Nebula" = {
        id = "nebula";
        url = "https://www.nebula.tv/featured";
        position = position + 1;
      };
      "Youtube" = {
        id = "yt";
        url = "https://www.youtube.com/feed/subscriptions";
        position = position + 2;
      };
      "Instagram" = {
        id = "instagram";
        url = "https://www.instagram.com/?variant=following";
        position = position + 3;
      };
      "Mastodon" = {
        id = "homelab_mastodon_instance";
        url = "https://mas.${homelabDomain}/home";
        position = position + 5;
      };
    };
  };
}
