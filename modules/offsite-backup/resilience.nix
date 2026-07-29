{ config, lib, ... }:
with lib;

let
  cfg = config.modules.offsiteBackup;
in
{
  config = mkIf cfg.enable {
    # Nobody will be there to wake this machine, and a suspended box neither
    # replicates nor answers its tunnel.
    systemd.targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };

    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleSuspendKey = "ignore";
      HandleHibernateKey = "ignore";
      IdleAction = "ignore";
    };

    powerManagement.enable = mkDefault false;

    # Boot even if something is wrong: an unattended machine that stops at the
    # bootloader or waits on a missing filesystem is unrecoverable remotely.
    boot.loader.timeout = mkDefault 1;
    systemd.enableEmergencyMode = false;

    # Replication and the tunnel both need a routable address, and DHCP on an
    # unknown network can be slow to settle.
    systemd.services.NetworkManager-wait-online.enable = mkDefault true;
  };
}
