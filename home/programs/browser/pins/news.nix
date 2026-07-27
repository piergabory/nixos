let
  position = 300;
in {
  programs.zen-browser.profiles.default.spaces.general.pins."News" = {
    inherit position;
    id = "news_group";
    isFolderCollapsed = true;
    pins = {
      "The Verge" = {
        id = "theverge";
        url = "https://www.theverge.com";
        position = position + 1;
      };
      "NYT" = {
        id = "nytimes";
        url = "https://www.nytimes.com";
        position = position + 2;
      };
      "Le Monde" = {
        id = "lemonde";
        url = "https://www.lemonde.fr";
        position = position + 3;
      };
      "The Guardian" = {
        id = "theguardian";
        url = "https://www.theguardian.com/europe";
        position = position + 4;
      };
    };
  };
}
