{
  config,
  lib,
  pkgs,
  ...
}:
let
  colors = config.lib.stylix.colors;

  colorRoles = {
    base00 = [
      "base-background"
      "base-background-mobile"
      "header-background"
      "footer-background"
      "result-image-background"
      "toolkit-tabs-label-border"
      "toolkit-checkbox-label-background"
      "toolkit-engine-tooltip-background"
      "loading-indicator-gap"
    ];
    base01 = [
      "sidebar-background"
      "backtotop-background"
      "search-background"
      "autocomplete-background"
      "answer-background"
      "result-keyvalue-even"
      "result-background"
      "result-detail-background"
      "toolkit-dialog-background"
      "doc-code-background"
    ];
    base02 = [
      "header-border"
      "footer-border"
      "sidebar-border"
      "backtotop-border"
      "show-btn-background"
      "search-border"
      "autocomplete-border"
      "autocomplete-background-hover"
      "result-keyvalue-col-table"
      "result-keyvalue-odd"
      "result-border"
      "result-vim-selected"
      "result-search-url-border"
      "result-detail-hr"
      "settings-tr-hover"
      "settings-table-group-background"
      "toolkit-badge-background"
      "toolkit-dialog-border"
      "toolkit-tabs-section-border"
      "toolkit-select-background"
      "toolkit-select-border"
      "toolkit-checkbox-onoff-off-background"
      "toolkit-checkbox-onoff-on-background"
      "toolkit-checkbox-label-border"
      "toolkit-engine-tooltip-border"
      "favicon-background-color"
      "favicon-border-color"
    ];
    base03 = [
      "toolkit-select-background-hover"
      "toolkit-checkbox-onoff-off-mark-background"
    ];
    base04 = [
      "result-publishdate-font"
      "result-engines-font"
      "settings-engine-description-font"
      "result-detail-label-font"
      "line-number"
    ];
    base05 = [
      "base-font"
      "sidebar-font"
      "backtotop-font"
      "show-btn-font"
      "search-font"
      "autocomplete-font"
      "answer-font"
      "result-url-font"
      "result-search-url-font"
      "result-image-span-font"
      "result-detail-font"
      "toolkit-badge-font"
      "toolkit-input-text-font"
      "doc-code"
    ];
    base06 = [
      "result-description-highlight-font"
      "toolkit-kbd-background"
    ];
    base08 = [ "error" ];
    base0A = [
      "btn-background"
      "search-background-hover"
      "warning"
      "categories-item-selected-font"
      "categories-item-border-selected"
      "result-vim-arrow"
      "toolkit-checkbox-onoff-on-mark-background"
      "toolkit-checkbox-input-border"
      "bar-chart-secondary"
    ];
    base0B = [ "success" ];
    base0D = [
      "url-font"
      "result-link-font"
      "result-link-font-highlight"
      "result-detail-link"
      "bar-chart-primary"
    ];
    base0E = [
      "url-visited-font"
      "result-link-visited-font"
    ];
  };

  darkStyles =
    lib.concatStringsSep "\n" (
      lib.flatten (
        lib.mapAttrsToList (
          base: roles: map (role: "--color-${role}: #${colors.${base}};") roles
        ) colorRoles
      )
    )
    + ''

      color-scheme: dark;
      --color-base-font-rgb: ${colors.base05-rgb-r}, ${colors.base05-rgb-g}, ${colors.base05-rgb-b};
      --color-btn-font: #${colors.base00};
      --color-result-image-span-font-selected: #${colors.base00};
      --color-toolkit-kbd-font: #${colors.base00};
      --color-toolkit-checkbox-onoff-on-mark-color: #${colors.base00};
      --color-toolkit-checkbox-onoff-off-mark-color: #${colors.base00};
      --color-error-background: #${colors.base08}22;
      --color-warning-background: #${colors.base0A}22;
      --color-success-background: #${colors.base0B}22;
      --color-search-shadow: 0 2px 8px #${colors.base00}80;
      --color-autocomplete-shadow: 0 2px 8px #${colors.base00}80;
      --color-result-detail-loader-border: #${colors.base05}33;
      --color-result-detail-loader-borderleft: transparent;
      --color-toolkit-loader-border: #${colors.base05}33;
      --color-toolkit-loader-borderleft: transparent;
      --color-image-resolution-background: #${colors.base00}80;
      --color-image-resolution-font: #${colors.base05};
      --color-loading-indicator: #${colors.base05}33;
    '';

  stylesheetContents = ''
    #main_index .index > .title,
    #search_logo {
      display: none;
    }

    :root.theme-dark, :root.theme-black {
      ${darkStyles}
    }
    @media (prefers-color-scheme: dark) {
      :root.theme-auto {
        ${darkStyles}
      }
    }
  '';
  stylesheet = pkgs.writeText "searxng-stylix.css" stylesheetContents;
  stylesheetName = "stylix-${
    builtins.substring 0 12 (builtins.hashString "sha256" stylesheetContents)
  }.css";
in
{
  config = lib.mkIf (config.services.searx.enable && config.stylix.enable) {
    services.searx = {
      settings = {
        ui = {
          default_theme = "simple";
          theme_args.simple_style = "dark";
        };
        brand.pwa_colors = {
          theme_color_dark = "#${colors.base0A}";
          background_color_dark = "#${colors.base00}";
          theme_color_black = "#${colors.base0A}";
          background_color_black = "#${colors.base00}";
        };
      };

      package = pkgs.searxng.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          searx="$out/${pkgs.python3.sitePackages}/searx"
          install -m 444 ${stylesheet} "$searx/static/themes/simple/${stylesheetName}"
          substituteInPlace "$searx/templates/simple/base.html" \
            --replace-fail '</head>' \
              "<link rel=\"stylesheet\" href=\"{{ url_for('static', filename='${stylesheetName}') }}\" type=\"text/css\"></head>"
        '';
      });
    };
  };
}
