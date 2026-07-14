{ config, ... }:

let
  # keyd's `include` mechanism rejects the NixOS symlink layout (its path-escape
  # guard fails because /etc/keyd/layouts points into a different store path than
  # /etc/keyd). So instead inline the bundled `fr` layout directly at build time.
  frLayout = builtins.readFile "${config.services.keyd.package}/share/keyd/layouts/fr";
in
{
  services.keyd = {
    enable = true;

    keyboards = {
      # Keychron Q6 -> French (AZERTY) with real accents (é è à ç ù ...).
      # keyd's bundled `fr` layout produces the French characters itself,
      # independent of the system XKB layout (which stays `us`).
      keychron = {
        ids = [ "k:3434:0163" ];
        settings.global.default_layout = "fr";
        extraConfig = frLayout;
      };

      # Kinesis Adv360 -> US-International-style dead keys. Compose must be
      # enabled in the compositor for these mappings to produce accents.
      kinesis = {
        ids = [ "k:29ea:0360" ];
        settings = {
          main = {
            apostrophe = "macro(compose apostrophe)";
            grave = "macro(compose grave)";
          };
          shift = {
            apostrophe = "macro(compose S-apostrophe)";
            grave = "macro(compose S-grave)";
          };
        };
      };
    };
  };
}
