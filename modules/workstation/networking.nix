{ ... }:

{
  # Pin the ethernet NIC to a stable name by MAC address,
  # immune to PCIe bus renumbering (e.g. adding/removing NVMe drives).
  systemd.network.links."10-ethernet" = {
    matchConfig.MACAddress = "34:5a:60:ea:c7:d6";
    linkConfig.Name = "eth0";
  };

  networking = {
    hostName = "workstation";
    networkmanager.enable = true;

    firewall = {
      allowedTCPPorts = [
        22 # openssh
        80 # HTTP
        443 # HTTPS
      ];
    };
  };
}
