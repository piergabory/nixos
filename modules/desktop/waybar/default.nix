{ config, lib, ... }:
with lib;

let
  cfg = config.programs.waybar;
in {
  imports = [
    ./laptop.nix
  ];

  config = mkIf cfg.enable {
    programs.waybar = {
      settings.primary = {
        height = 24;

        modules-left = [ "niri/window" ];
        modules-center = [ ];
        modules-right = [
          "clock"
        ];

        "niri/workspaces".format = "{index}";
        "niri/window" = {
          format = "{title}";
          separate-outputs = true;
        };
        "clock" = {
          format = "{:%x %H:%M}";
        };
      };

      style = mkAfter ''
        * {
            font-family: monospace;
            background: none;
            border: none;
            outline: none;
            box-shadow: none;
            border: none;
            border-radius: 0;
            border-bottom-width: 0;
            outline-width: 0;
        }

        button:not(:active), button:not(:selected), button:not(:focused) {
            opacity: 0.75;
        }

        window#waybar {
          background: transparent;
        }

        window#waybar>box {
          margin: 0 20px;
        }

        #workspaces button {
            padding: 0 6px;
            margin: 6px;
            min-height: 6px;
            min-width: 10px;
            background: @theme_base_color;
            color: transparent;
            opacity: 0.8;
            border-bottom: transparent;
        }

        #workspaces button:focus {
            background: @theme_text_color;
            border-bottom: transparent;
        }
      '';
    };
  };
}
