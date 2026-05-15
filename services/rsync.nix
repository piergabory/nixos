{ ... }:

{
  services.rsync = {
    enable = true;

    
    jobs.documents = {
      sources = [ "/home/piergabory/Documents/" ];
      destination = "/storage/documents/";

      settings = {
        archive = true;
        delete = true;
        human-readable = true;
        mkpath = true;
      };

      user = "piergabory";
      group = "users";

      timerConfig = {
        OnCalendar = "*:0/5";
        Persistent = true;
      };
    };

    jobs.music = {
      sources = [ "/home/piergabory/Music/" ];
      destination = "/storage/jellyfin/music";

      settings = {
        archive = true;
        delete = true;
        human-readable = true;
        mkpath = true;
      };

      user = "piergabory";
      group = "users";

      timerConfig = {
        OnCalendar = "*:0/5";
        Persistent = true;
      };
    };
  };
}
