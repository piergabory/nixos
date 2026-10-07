{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

let
  cfg = config.services.minecraft-server;
in
{
  imports = [
    ./backup.nix
    ./whitelist.nix
    ./properties.nix
  ];

  config = {
    services.minecraft-server = mkIf cfg.enable {
      eula = true;
      openFirewall = true;
      package = pkgs.minecraft-server;
      dataDir = "/var/lib/minecraft";
      declarative = true;

      # 512MB to 4GB, clean up every 60ish seconds
      jvmOpts = ''
        -Xms512M \
        -Xmx2G \
        -XX:MaxHeapFreeRatio=30 \
        -XX:MinHeapFreeRatio=10 \
        -XX:+UseG1GC \
        -XX:G1PeriodicGCInterval=60000
      '';
    };
  };
}
