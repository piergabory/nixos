{ config, lib, ... }:
with lib;

let
  domain = config.modules.homelab.domain;
  cfg = config.services.mastodon;
in
{
  imports = [
    ./backup.nix
  ];

  config = mkIf cfg.enable {
    services.mastodon = {
      localDomain = "mas.${domain}";
      configureNginx = true;
      smtp.fromAddress = "no_reply@${domain}";
      streamingProcesses = 1;
      extraConfig.SINGLE_USER_MODE = "true";
    };
  };
}
