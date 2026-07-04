{ ... }:

{
  imports = [
    ./glance
    ./logind.nix
    ./geotracking.nix
    ./authelia.nix
    ./backup.nix
    ./budget.nix
    ./home-assistant.nix
    ./immich.nix
    ./jellyfin.nix
    ./mastodon.nix
    ./mdadm.nix
    ./minecraft-server.nix
    ./nginx.nix
    ./pihole.nix
    ./postfix.nix
    ./radicale.nix
    ./resolved.nix
    ./rsync.nix
    ./samba.nix
    ./syncthing.nix
    ./vaultwarden.nix
    ./media-server.nix
    ./notes.nix
    ./flights.nix
  ];
}
