{
  config,
  isDarwin,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cfg = config.mainUser;
in
{
  imports = [
    ./locale.nix
    ./home-manager.nix
  ];

  options.mainUser = {
    enable = mkEnableOption "Activate profile for Pierre Gabory";
    username = mkOption {
      type = types.str;
      default = "piergabory";
    };
    description = mkOption {
      type = types.str;
      default = "Pierre Gabory";
    };
    homeDirectory = mkOption {
      type = types.str;
      default = "/home/${cfg.username}";
    };
    homeConfiguration = mkOption {
      type = types.deferredModule;
      default = { };
    };
    userConfiguration = mkOption {
      type = types.attrs;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    users.users."${cfg.username}" = {
      name = cfg.username;
      home = cfg.homeDirectory;

      description = cfg.description;
      shell = pkgs.zsh;
    }
    // optionalAttrs (!isDarwin) {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    }
    // cfg.userConfiguration;

    nix.settings.trusted-users = [
      cfg.username
    ];

    services =
      { }
      // optionalAttrs (!isDarwin) {
        accounts-daemon.enable = true;
      };

    environment.etc."AccountsService/users/${cfg.username}".text = ''
      [User]
      Icon=${../../assets/pierre.jpg}
    '';
  };
}
