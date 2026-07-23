{ ... }:

let
  samba_user = "piergabory";
in

{
  services.samba = {
    enable = true;
    openFirewall = true; # Automatically opens TCP ports 139 and 445

    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "workstation";
        "netbios name" = "workstation";
        "security" = "user";
        "hosts allow" = "192.168.1. 127.0.0.1 localhost"; # Allows all subnet ips
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };

      public = {
        "path" = "/data/nas/public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = samba_user;
      };

      "home" = {
        "path" = "/home/${samba_user}";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "valid users" = samba_user;
      };

      "storage" = {
        "path" = "/storage";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "valid users" = samba_user;
      };
    };
  };

  # Windows Service Discovery Daemon (Makes the server visible in Windows Network)
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;

    publish = {
      enable = true;
      userServices = true;
      hinfo = true;
      addresses = true;
      domain = true;
      workstation = true;
    };

    extraServiceFiles = {
      smb = ''
        <?xml version="1.0" standalone='no'?><!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
          <service>
            <type>_device-info._tcp</type>
            <port>0</port>
            <txt-record>model=MacPro5,1</txt-record>
          </service>
        </service-group>
      '';
    };
  };
}
