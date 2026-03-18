# Define default apps with XDG (X Desktop Group)
{ ... }:

{
  xdg.mimeApps.defaultApplications = {
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
}
