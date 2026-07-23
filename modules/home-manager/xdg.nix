{ config, ... }:

{
  xdg.mimeApps.defaultApplications = {
    # Make a imv module
    "image/png" = "imv.desktop";
    "image/jpg" = "imv.desktop";
    "image/jpeg" = "imv.desktop";
    "image/bmp" = "imv.desktop";
    "image/gif" = "imv.desktop";
    "image/webp" = "imv.desktop";
    "image/tiff" = "imv.desktop";
    "image/svg+xml" = "imv.desktop";
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    desktop = "~/Desktop";
    documents = "~/Documents";
    download = "~/Downloads";
    music = "~/Music";
    pictures = "~/Pictures";
    publicShare = "~/Public";
    templates = "~/Templates";
    videos = "~/Videos";
  };

  gtk = {
    enable = true;
    gtk3.bookmarks = [
      "file://${config.home.homeDirectory}/Desktop"
      "file://${config.home.homeDirectory}/Documents"
      "file://${config.home.homeDirectory}/Downloads"
      "file://${config.home.homeDirectory}/Music"
      "file://${config.home.homeDirectory}/Pictures"
      "file:///storage"
      "file:///mnt/home-server/public"
      "file:///mnt/home-server/home"
      "file:///mnt/home-server/storage"
    ];
  };
}
