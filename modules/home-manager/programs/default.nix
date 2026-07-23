{ ... }:

{
  imports = [
    ./beets.nix
    ./browser.nix
    ./packages.nix
  ];

  config = {
    programs = {
      obsidian.enable = true;
      btop.enable = true;
      rmpc.enable = true;

      thunderbird = {
        enable = true;
        languagePacks = [ "en-US" "en-UK" "fr" ];
      };

      foot = {
        enable = true;
        server.enable = true;
        settings.main.pad = "8x8";
      };

      vicinae = {
        enable = true;
        systemd.enable = true;
      };
    };
  };
}
