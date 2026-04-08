{ pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --sessions ${pkgs.greetd.tuigreet}/share/wayland-sessions";
        user = "greeter";
      };
    };
  };
}
