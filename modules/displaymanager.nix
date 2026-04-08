{ pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --sessions ${pkgs.tuigreet}/share/wayland-sessions";
        user = "greeter";
      };
    };
  };
}
