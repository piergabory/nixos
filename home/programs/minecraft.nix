{ config, lib, pkgs, ... }:

let
  xwaylandDisplay = ":12";
  minecraft-prism = pkgs.writeShellScriptBin "minecraft-prism" ''
    set -eu

    systemctl --user start xwayland-satellite-minecraft.service || true
    export DISPLAY=${xwaylandDisplay}
    export _JAVA_AWT_WM_NONREPARENTING=1
    exec ${pkgs.prismlauncher}/bin/prismlauncher "$@"
  '';
in
lib.mkIf (config.home.username == "piergabory") {
  home.packages = with pkgs; [
    minecraft-prism
    prismlauncher
    xwayland-satellite
  ];

  systemd.user.services.xwayland-satellite-minecraft = {
    Unit = {
      Description = "Xwayland satellite for Minecraft on Niri";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite ${xwaylandDisplay}";
      Restart = "on-failure";
      RestartSec = 2;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };

  programs.niri.settings.spawn-at-startup = [
    { argv = [ "systemctl" "--user" "start" "xwayland-satellite-minecraft.service" ]; }
  ];

  home.sessionVariables = {
    MINECRAFT_DISPLAY = xwaylandDisplay;
  };
}
