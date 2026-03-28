# Flatpak packages for when nix fails

{ ... }:

{
  services.flatpak = {
    enable = true;
    remotes = {
      "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    };
    packages = [
      # Epson Scan 2 (Crashes on preview)
      # "flathub:app/net.epson.epsonscan2/x86_64/master"
      # Vuescan (liscence expired)
      # "flathub:app/com.hamrick.VueScan/x86_64/stable"
    ];
  };
}
