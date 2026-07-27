let

  root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMga0Y7kXjR5Dk3KrcbmuuXFPu7OTZu0LlxcwQKmibyn root@nixos";
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxza02BCdSvMbPQxEbQApkRwWQ7/idM+DmevYJjhmPM root@workstation";
  thinkpadRoot = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH3AauF9raJ3/hMUPdNPqaRbg2mTBk4efylMvSAOaG2S root@thinkpad";
  thinkpadSystem = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILVaLgeww5DZ0ZU2l92IF5CFTsau/kjEDeIwtmVhWXtb root@thinkpad";
  offsiteRoot = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKuRnatqXTEh4liurVS8LNOI3njCSVmOHt2Qs5TVYHXT root@offsite";
  offsiteSystem = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHf8xIos3OZiw/V7IwItIbskxTCRh2t+fD0Stc9SG5n root@nixos";
  keys = [
    root
    system
    thinkpadRoot
    thinkpadSystem
    offsiteRoot
    offsiteSystem
  ];
in
{
  "gui.age".publicKeys = keys;
}
