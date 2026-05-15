{ config, ... }:

let
  widgets = import ./widgets { inherit config; };
in

{
  services.glance.settings.pages = [
    {
      name = "Dashboard";
      columns = [
        {
          size = "full";
          widgets = widgets.main;
        }
        {
          size = "small";
          widgets = widgets.aside;
        }
      ];
    }
  ];
}
