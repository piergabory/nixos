let
  position = 800;
in
{
  programs.zen-browser.profiles.default.spaces.general.pins."Shop" = {
    inherit position;
    id = "shop_group";
    isFolderCollapsed = true;
    pins = {
      "Leboncoin" = {
        id = "leboncoin";
        url = "https://www.leboncoin.fr/favorites";
        position = position + 1;
      };
      "Ebay" = {
        id = "ebay";
        url = "https://www.ebay.fr";
        position = position + 2;
      };
      "Polaroid" = {
        id = "polaroid";
        url = "https://www.polaroid.com/fr_fr";
        position = position + 3;
      };
      "Amazon" = {
        id = "amazon";
        url = "https://www.amazon.fr";
        position = position + 4;
      };
    };
  };
}
