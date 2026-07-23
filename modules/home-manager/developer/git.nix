{
  config = {
    programs = {
      git = {
        enable = true;
        settings.user = {
          name = "Pierre Gabory";
          email = "mail@piergabory.net";
          init.defaultBranch = "main";
          pull.rebase = true;
          push.autoSetupRemote = true;
        };
      };

      lazygit = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
