{
  inputs,
  lib,
  pkgs,
  isDarwin ? false,
  isDroid ? false,
  ...
}:

{
  imports = with inputs.stylix; [
    (
      if isDroid then
        nixOnDroidModules.stylix
      else if isDarwin then
        darwinModules.stylix
      else
        nixosModules.stylix
    )
  ];

  config = {
    stylix = lib.mkMerge (
      [
        {
          enable = true;
          autoEnable = true;
          overlays.enable = lib.mkIf isDroid false;
          image = ../assets/house.jpg;
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
        }
      ]
      ++ lib.optional (!isDroid && !isDarwin) {
        targets.gtk.enable = false;
      }
    );
  };
}
