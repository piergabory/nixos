let
  position = 500;
in
{
  programs.zen-browser.profiles.default.spaces.general.pins."Developer" = {
    inherit position;
    id = "developer_group";
    isFolderCollapsed = true;
    pins = {
      "Codeberg" = {
        id = "codeberg";
        url = "https://codeberg.org/";
        position = position + 1;
      };
      "Github" = {
        id = "github";
        url = "https://github.com";
        position = position + 2;
      };
      "Nix Packages" = {
        id = "nix_packages";
        url = "https://search.nixos.org/packages?channel=unstable";
        position = position + 3;
      };
      "Home Manager Options" = {
        id = "nix_home_manager_options";
        url = "https://home-manager-options.extranix.com/?query=&release=master";
        position = position + 4;
      };
    };
  };
}
