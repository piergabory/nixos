{ config, lib, ... }:
with lib;

let
  cfg = config.services.mastodon;
in {
  imports = [
    ./backup.nix
  ];

  config = mkIf cfg.enable {
    services.mastodon = {
      localDomain = "mas.pierr.re";
      configureNginx = true;
      smtp.fromAddress = "no_reply@pierr.re";
      streamingProcesses = 1;
      extraConfig.SINGLE_USER_MODE = "true";
    };
  };
}
