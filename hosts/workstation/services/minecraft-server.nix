{ config, pkgs, ... }:

let
  minecraftServer_26_1_2 = pkgs.minecraft-server.override {
    jre_headless = pkgs.jdk25_headless;
    version = "26.1.2";
    url = "https://piston-data.mojang.com/v1/objects/97ccd4c0ed3f81bbb7bfacddd1090b0c56f9bc51/server.jar";
    sha1 = "97ccd4c0ed3f81bbb7bfacddd1090b0c56f9bc51";
  };
in

{
  services.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true;
    package = minecraftServer_26_1_2;
    dataDir = "/var/lib/minecraft";
    declarative = true;

    whitelist = {
      # username = "UUID";
      Piergabory = "0c2fe76f-68fc-405f-8aee-5c4e5c75df2b";
      Stoltheds = "133b7c57-40bb-4e1f-aa51-c28d1289457e";
      thingthingXXII = "6c599a32-26d2-4c91-be49-f888a678d66c";
      CCheezit = "360e7261-b9a9-4c3f-993b-f42b9cb90a38";
      rtdu24 = "cc457ba0-68ab-4bad-9040-9e2c63d791a8";
      Pierrot = "8c067c90-9848-4272-af30-72e53e20da13";
      vval = "02ed6a53-03b2-45a9-b395-f770e4e91f44";
      Sadaroh = "e23b1222-3dd3-4880-a230-47c3fdad859f";
      Sippyz = "f8b56dbf-2429-4ec7-87f3-8230c53d7584";
      Armetick = "7a1e821b-08db-44a8-aee7-59073d5d7505";
      Appleju = "0df9b36f-0227-4206-93cd-d140eb88b845";
      Kagarino = "096a5986-8b76-48b5-9877-2bab5a13721e";
      catemi = "1c6f7bba-5b79-40a0-9218-d8aeae6f2da6";
      thedinghy = "21161988-82e8-4173-b85b-9f580b1dd66f";
    };

    serverProperties = {
      server-port = 25565;
      difficulty = 3;
      gamemode = 0;
      max-players = 5;
      motd = "Pierre's Minecraft server! MSG @piergabory for whitelist";
      white-list = true;
      view-distance = 20;
      spawn-protection = 0;
    };
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

  services.restic.backups.minecraft = {
    inherit (config.piergabory.backups) repository passwordFile pruneOpts;
    initialize = true;
    timerConfig = config.piergabory.backups.timerConfig // {
      OnCalendar = "03:00";
    };
    paths = [
      "/var/lib/minecraft/world"
    ];
    backupPrepareCommand = ''
      if ${pkgs.systemd}/bin/systemctl is-active --quiet minecraft-server.service; then
        touch /run/restic-backups-minecraft/minecraft-was-active
        ${pkgs.systemd}/bin/systemctl stop minecraft-server.service
      fi
    '';
    backupCleanupCommand = ''
      if [ -e /run/restic-backups-minecraft/minecraft-was-active ]; then
        rm /run/restic-backups-minecraft/minecraft-was-active
        ${pkgs.systemd}/bin/systemctl start minecraft-server.service
      fi
    '';
    extraBackupArgs = [
      "--tag minecraft"
      "--one-file-system"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 25565 ];
}
