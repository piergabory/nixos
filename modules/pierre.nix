{
  config,
  lib,
  pkgs,
  useDarwinModule,
  ...
}:
with lib;

let
  cfg = config.pierre;
in
{
  options.pierre = {
    enable = mkEnableOption "Activate profile for Pierre Gabory";
    username = mkOption {
      type = types.str;
      default = "piergabory";
    };
    home = mkOption {
      type = types.str;
      default = "/home/${cfg.username}";
    };
  };

  config = {
    users.users."${cfg.username}" = {
      name = cfg.username;
      home = cfg.home;

      description = "Pierre Gabory";
      shell = pkgs.zsh;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5tBVh+IFkng8sPxKroP3EZ9LfIC+Q2A9W8wOnDKJUV piergabory@thinkpad"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPFsc6h97lG4SHJTnmUzbmcbaIXU8O/NstwxP6WkvC+G pgabory@FR318LM015.local"
      ];
    };

    nix.settings.trusted-users = [
      cfg.username
    ];

    time.timeZone = mkDefault "Europe/Paris";

  }
  // (
    if useDarwinModule then
      { 
	home-manager.managed-users = [ cfg.username ];
}
    else
      {
        users.users."${cfg.username}" = {
          extraGroups = [ "wheel" ];
          isNormalUser = true;
        };

        home-manager = {
          managed-users = [ cfg.username ];

          users."${cfg.username}".home = {
            username = cfg.username;
            homeDirectory = cfg.home;
          };
        };

        console.keyMap = mkDefault "fr";

        i18n = {
          defaultLocale = "en_US.UTF-8";

          extraLocaleSettings = {
            LC_ADDRESS = "fr_FR.UTF-8";
            LC_IDENTIFICATION = "fr_FR.UTF-8";
            LC_MEASUREMENT = "fr_FR.UTF-8";
            LC_MONETARY = "fr_FR.UTF-8";
            LC_NAME = "fr_FR.UTF-8";
            LC_NUMERIC = "fr_FR.UTF-8";
            LC_PAPER = "fr_FR.UTF-8";
            LC_TELEPHONE = "fr_FR.UTF-8";
            LC_TIME = "fr_FR.UTF-8";
          };
        };
      }
  );
}
