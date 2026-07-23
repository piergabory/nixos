{ ... }:

{
  programs.zed-editor = {
    enable = true;

    extensions = [
      "git-firefly"
    ];

    userSettings = {
      vim_mode = true;
      feature = {
        copilot = true;
      };
    };
  };
}
