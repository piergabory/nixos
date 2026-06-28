# Define default apps with XDG (X Desktop Group)
{ config, lib, ... }:

{
  xdg.mimeApps.defaultApplications = {
    "inode/directory" = "Thunar.desktop";
    "application/x-gnome-saved-search" = "Thunar.desktop";
    # Image formats, use IMV
    "image/png" = "imv.desktop";
    "image/jpg" = "imv.desktop";
    "image/jpeg" = "imv.desktop";
    "image/bmp" = "imv.desktop";
    "image/gif" = "imv.desktop";
    "image/webp" = "imv.desktop";
    "image/tiff" = "imv.desktop";
    "image/svg+xml" = "imv.desktop";
  };

  xdg.userDirs = lib.mkIf (config.home.username == "piergabory") {
    enable = true;
    createDirectories = true;

    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    publicShare = "${config.home.homeDirectory}/Public";
    templates = "${config.home.homeDirectory}/Templates";
    videos = "${config.home.homeDirectory}/Videos";
  };

  gtk = lib.mkIf (config.home.username == "piergabory") {
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
