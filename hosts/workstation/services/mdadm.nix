{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mdadm # Software RAID for /storage
  ];

  boot.swraid = {
    enable = true;
    mdadmConf = ''
      MAILADDR mail@piergabory.net
    '';
  };
}
