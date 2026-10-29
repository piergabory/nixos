{
  config,
  lib,
  pkgs,
  ...
}:

let
  colors = config.lib.stylix.colors;
  recipeID = "E2C58A1D-5B24-4B5F-9D34-1B3EE356A371";
  color = name: { _0.oklchColor = colors.${name}; };

  mkFont = size: identifier: weight: {
    family.custom._0 = "IoskeleyMono Nerd Font Mono";
    inherit size;
    variant = {
      inherit identifier weight;
      slant.value = 0;
      width.value = 0;
    };
  };

  mkCategory = category: size: automaticSize: [
    { ${category} = { }; }
    {
      category.${category} = { };
      displayModes = [
        { standard = { }; }
        {
          category.${category} = { };
          content.custom = {
            inherit automaticSize;
            dark = mkFont size "IoskeleyMonoNFM-Medium" 5;
            light = mkFont size "IoskeleyMonoNFM" 4;
          };
        }
      ];
    }
  ];

  tokenColors = {
    keyword = "base0E";
    "keyword.attribute" = "base0A";
    number = "base09";
    "number.character" = "base09";
    string = "base0B";
    "string.regex" = "base0C";
    comment = "base03";
    commentEmphasized = "base04";
    otherType = "base0A";
    typeDeclaration = "base0A";
    otherMember = "base0D";
    memberDeclaration = "base0D";
    preprocessor = "base0C";
    link = "base0D";
    plainText = "base05";
    invisibles = "base03";
    selectedTextBackgroundColor = "base02";
    currentLineHighlight = "base01";
    insertionPointColor = "base05";
  };

  recipe = {
    background.customColor = color "base00";
    colorScheme.dark = { };
    palette = {
      colorGranularity = "expanded";
      colorOverrides = lib.concatLists (
        lib.mapAttrsToList (token: base: [
          token
          { color = color base; }
        ]) tokenColors
      );
      primary.custom = color "base05";
      secondary.custom = color "base01";
    };
  };

  preferences = import ./preferences {
    inherit pkgs;
    name = "stylix-xcode";
    settings = {
      domain = "com.apple.dt.Xcode";
      process = "Xcode";
      upsertJSON.DVTWorkspaceSavedRecipes = {
        id = recipeID;
        name = "Stylix Gruvbox Dark";
        # Keep the generated recipe deterministic rather than using build time.
        lastUsedDate = 0.0;
        inherit recipe;
      };
      mergeJSON.DVTWorkspaceThemeSettings.dark.savedRecipe._0 = recipeID;
      set.DVTWorkspaceGlobalFontRecipe.jsonData = {
        fonts =
          (mkCategory "prose" 16 true) ++ (mkCategory "code" 14 false) ++ (mkCategory "console" 14 false);
        lineSpacing.normal = { };
      };
    };
  };
in
{
  home.activation.stylixXcode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${preferences}
  '';
}
