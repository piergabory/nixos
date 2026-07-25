{ config, lib, pkgs, ... }:
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

      isNormalUser = true;
      description = "Pierre Gabory";
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5tBVh+IFkng8sPxKroP3EZ9LfIC+Q2A9W8wOnDKJUV piergabory@thinkpad"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPFsc6h97lG4SHJTnmUzbmcbaIXU8O/NstwxP6WkvC+G pgabory@FR318LM015.local"
      ];
    };

    home-manager = {
      managed-users = [ cfg.username ];

      users."${cfg.username}".home = {
        username = cfg.username;
        homeDirectory = cfg.home;
      };
    };

    nix.settings.trusted-users = [
      cfg.username
    ];

    time.timeZone = "Europe/Paris";

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
  };
}
