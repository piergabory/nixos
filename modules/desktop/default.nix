{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cfg = config.modules.graphicalDesktop;
in
{
  options.modules.graphicalDesktop = {
    enable = mkEnableOption "Graphical Destop Interface";
  };

  config = mkIf cfg.enable {
    services.displayManager = {
      defaultSession = "niri";
      sddm.enable = true;
    };
    services.desktopManager.plasma6.enable = true;
    stylix.targets.qt.platform = mkForce "qtct";

    programs = {
      niri = {
        enable = true;
      };
      xwayland.enable = true;
    };

    environment.systemPackages = with pkgs; [
      kdePackages.akonadi
      kdePackages.ark
      kdePackages.breeze-icons
      kdePackages.dolphin
      kdePackages.gwenview
      kdePackages.kaddressbook
      kdePackages.kmail
      kdePackages.korganizer
      kdePackages.okular
    ];

    mainUser.homeConfiguration = {
      imports = [
        inputs.niri.homeModules.niri
        ./niri
        ./waybar
      ];
      programs = {
        niri = {
          enable = true;
          package = pkgs.niri;
          settings.input.keyboard.xkb =
            let
              xkb = config.services.xserver.xkb;
            in
            {
              layout = xkb.layout;
              variant = xkb.variant;
            };
        };
        waybar.enable = true;
      };
      systemd.user.services.akonadi-control = {
        Unit = {
          Description = "Akonadi Control";
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          BusName = "org.freedesktop.Akonadi.Control";
          ExecStart = "${pkgs.kdePackages.akonadi}/bin/akonadi_control";
          Type = "dbus";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
      services.mako.enable = true;
      xdg.portal.extraPortals = mkForce [
        pkgs.kdePackages.xdg-desktop-portal-kde
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };
}
