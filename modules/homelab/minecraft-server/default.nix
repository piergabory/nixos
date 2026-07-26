{ config, pkgs, lib, ... }:
with lib;

let
  cfg = config.services.minecraft-server;
in {
  imports = [
    ./backup.nix
    ./whitelist.nix
    ./properties.nix
  ];

  config = let
    minecraftServerPackage = with pkgs; callPackage "${path}/pkgs/by-name/mi/minecraft-server/derivation.nix" {
      jre_headless = jdk25_headless;
      version = "26.1.2";
      url = "https://piston-data.mojang.com/v1/objects/97ccd4c0ed3f81bbb7bfacddd1090b0c56f9bc51/server.jar";
      sha1 = "97ccd4c0ed3f81bbb7bfacddd1090b0c56f9bc51";
    };
  in {
    services.minecraft-server = mkIf cfg.enable {
      eula = true;
      openFirewall = true;
      package = minecraftServerPackage;
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

    networking.firewall.allowedTCPPorts = [
      cfg.serverProperties.server-port
    ];
  };
}
