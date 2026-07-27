let
  position = 200;
in {
  programs.zen-browser.profiles.default.spaces.general.pins."Media" = {
    inherit position;
    id = "media_group";
    isFolderCollapsed = true;
    pins = {
      "Nebula" = {
        id = "nebula";
        url = "https://www.nebula.tv";
        position = position + 1;
      };
      "Youtube" = {
        id = "yt";
        url = "https://www.youtube.com/subscriptions/";
        position = position + 2;
      };
      "Instagram" = {
        id = "instagram";
        url = "https://www.instagram.com";
        position = position + 3;
      };
    };
  };
}
