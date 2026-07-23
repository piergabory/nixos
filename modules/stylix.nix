{ inputs, lib, pkgs, ... }:

{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  config = {
    stylix = {
      enable = true;
      autoEnable = true;
      polarity = "dark";
      base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";

      fonts = {
        sizes = {
          applications = lib.mkDefault 10;
          desktop = lib.mkDefault 10;
        };

        serif = {
          package = pkgs.garamond-libre;
          name = "Garamond Libre";
        };

        sansSerif = {
          package = pkgs.inter;
          name = "Inter";
        };

        monospace = {
          package = pkgs.nerd-fonts.fira-code;
          name = "FiraCode Nerd Font";
        };

        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
  };
}
