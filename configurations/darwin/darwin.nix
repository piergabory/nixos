{ config, ... }: {
  imports = [
    ../default.nix
  ];

  config = {
    mainUser.homeDirectory = "/Users/${config.mainUser.username}";

    home-manager.users.${config.mainUser.username} = {
      home.file = {
        ".config/opencode/AGENTS.md".source = ./ai/global/AGENTS.md;
        "Developer/AGENTS.md".source = ./ai/Developer/AGENTS.md;
        "Developer/.opencode/opencode.json".source = ./ai/opencode.json;
      };

      programs.git.includes = [
        {
          condition = "gitdir:~/Developer/netatmo/";
          contents.user.email = "pierre.gabory@legrand.com";
        }
      ];
    };

    # This value determines the Nix-Darwin release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    system.stateVersion = 7;
  };
}
