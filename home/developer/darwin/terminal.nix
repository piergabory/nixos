{
  config,
  lib,
  pkgs,
  ...
}:

let
  colors = config.lib.stylix.colors;
  profileName = "Stylix Gruvbox Dark";
  color = name: { archiveColor = colors.${name}; };

  profile = {
    name = profileName;
    type = "Window Settings";
    ProfileCurrentVersion = "2.09";
    # PostScript name of the font installed by modules/stylix.nix.
    Font.archiveFont = {
      name = "IoskeleyMonoNFM";
      size = 14;
    };
    FontAntialias = true;
    FontWidthSpacing = 1.0;
    FontHeightSpacing = 1.0;
    BackgroundColor = color "base00";
    TextColor = color "base05";
    TextBoldColor = color "base06";
    CursorColor = color "base0D";
    SelectionColor = color "base02";
    DynamicANSIForegroundColors = false;
    BackgroundBlur = 0.0;
    BackgroundSettingsForInactiveWindows = true;
  }
  // lib.mapAttrs (_: color) {
    ANSIBlackColor = "base00";
    ANSIRedColor = "base08";
    ANSIGreenColor = "base0B";
    ANSIYellowColor = "base0A";
    ANSIBlueColor = "base0D";
    ANSIMagentaColor = "base0E";
    ANSICyanColor = "base0C";
    ANSIWhiteColor = "base05";
    ANSIBrightBlackColor = "base03";
    ANSIBrightRedColor = "base08";
    ANSIBrightGreenColor = "base0B";
    ANSIBrightYellowColor = "base0A";
    ANSIBrightBlueColor = "base0D";
    ANSIBrightMagentaColor = "base0E";
    ANSIBrightCyanColor = "base0C";
    ANSIBrightWhiteColor = "base07";
  };

  preferences = import ./preferences {
    inherit pkgs;
    name = "stylix-terminal";
    settings = {
      domain = "com.apple.Terminal";
      process = "Terminal";
      merge."Window Settings".${profileName} = profile;
      set = {
        "Default Window Settings" = profileName;
        "Startup Window Settings" = profileName;
      };
    };
  };
in
{
  home.activation.stylixTerminal = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${preferences}
  '';
}
