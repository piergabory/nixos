{
  imports = [
    ./news.nix
    ./media.nix
    ./homelab.nix
    ./developer.nix
    ./work.nix
    ./chat.nix
  ];

  config.programs.zen-browser.profiles.default = {
    pinsForce = true;
    pinsForceAction = "demote";
    spacesForce = true;

    spaces.general = {
      id = "general";
      position = 1000;
    };
  };
}
