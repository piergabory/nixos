let

  root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMga0Y7kXjR5Dk3KrcbmuuXFPu7OTZu0LlxcwQKmibyn root@nixos";
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxza02BCdSvMbPQxEbQApkRwWQ7/idM+DmevYJjhmPM root@workstation";
  thinkpadRoot = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH3AauF9raJ3/hMUPdNPqaRbg2mTBk4efylMvSAOaG2S root@thinkpad";
  thinkpadSystem = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILVaLgeww5DZ0ZU2l92IF5CFTsau/kjEDeIwtmVhWXtb root@thinkpad";
  keys = [
    root
    system
    thinkpadRoot
    thinkpadSystem
  ];
in
{
  "gui.age".publicKeys = keys;
}
