{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.obsidian;
  plugins = import ./plugins.nix { inherit pkgs; };
in
{
  programs.obsidian = mkIf cfg.enable {
    vaults."Notes" = {
      enable = true;
      target = "./Notes";
    };

    defaultSettings = {
      appearance = {
        # "Obsidian gruvbox" is a community theme living in the (unmanaged)
        # `.obsidian/themes` directory, installed from the Obsidian UI.
        cssTheme = "Obsidian gruvbox";
        baseFontSize = 14;
      };

      app = {
        vimMode = true;
        readableLineLength = true;
        showLineNumber = true;
        useMarkdownLinks = true;
        alwaysUpdateLinks = true;
        newLinkFormat = "relative";
        tabSize = 2;
        showInlineTitle = false;
        openBehavior = "daily";
        promptDelete = false;
        mobileToolbarCommands = [
          "editor:toggle-checklist-status"
          "editor:unindent-list"
          "editor:indent-list"
          "editor:toggle-bullet-list"
          "editor:toggle-numbered-list"
          "editor:set-heading"
          "editor:undo"
          "editor:redo"
          "editor:attach-file"
          "editor:configure-toolbar"
        ];
      };

      # Community plugin settings are rendered to a read-only `data.json`
      # symlink, so these plugins must be configured from here rather than
      # from the Obsidian UI.
      communityPlugins = [
        {
          pkg = plugins.file-cleaner-redux;
          settings = {
            deletionDestination = "system"; # system | obsidian | permanent
            obsidianTrashCleanupAge = -1;
            deletionConfirmation = true;
            notifications = "showAll";

            excludeInclude = 0; # 0 = treat excludedFolders as an exclude list
            excludedFolders = [ ];

            attachmentsExcludeInclude = 1; # 1 = only the listed extensions
            attachmentExtensions = [ ];

            deleteEmptyMarkdownFiles = true;
            deleteEmptyMarkdownFilesWithBacklinks = false;
            deleteEmptyFileOnClose = true;
            removeFolders = false;
            runOnStartup = true;
            closeNewTabs = true;
            fileAgeThreshold = 0;

            ignoredFrontmatter = [ ];
            ignoreAllFrontmatter = false;
            codeblockTypes = [ ];

            ExternalPlugins.Excalidraw.TreatAsAttachments = false;
          };
        }
        {
          pkg = plugins.todo-sort;
          settings = {
            sortOrder = "completed-top"; # completed-top | completed-bottom
            delayMs = 250;
          };
        }
      ];
    };
  };

  # Obsidian is themed by the "Obsidian gruvbox" community theme rather than
  # by Stylix; leaving the target enabled would override `cssTheme`-adjacent
  # appearance settings (notably forcing `baseFontSize` back to 10).
  stylix.targets.obsidian.enable = false;
}
