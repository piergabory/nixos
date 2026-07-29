{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.modules.offsiteBackup;
in
{
  config = mkIf (cfg.enable && cfg.tunnel.enable) {
    # Once this machine sits behind a router nobody will ever configure, an
    # outbound tunnel it re-establishes itself is the only way back in. It is
    # reached from a trusted machine as: ssh -p <remotePort> localhost
    systemd.services.offsite-backup-tunnel = {
      description = "Reverse SSH tunnel exposing this machine to the home-lab";

      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = concatStringsSep " " [
          "${cfg.sshWrapper}/bin/ssh"
          "-N"
          "-o ExitOnForwardFailure=yes"
          # The bind address is spelled out on purpose. "-R port:host:hostport"
          # sends an empty bind address, which does not match a PermitListen
          # rule that names one, and the server then refuses the forward.
          "-R 127.0.0.1:${toString cfg.tunnel.remotePort}:127.0.0.1:22"
          "offsite-backup-tunnel"
        ];

        # Never give up: the link, the router and the far end will all go away
        # from time to time, and nobody is present to restart anything.
        Restart = "always";
        RestartSec = "15s";
      };

      unitConfig.StartLimitIntervalSec = 0;
    };
  };
}
