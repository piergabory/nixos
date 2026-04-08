{ lib, ... }:

{
  programs.foot = {
    enable = true;
    server.enable = true;
    settings.main.pad = "8x8";
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "[](bg:blue fg:black)"
        "$directory"
        "[](bg:yellow fg:blue)"
        "$git_branch"
        "$git_status"
      ];
      username = {
        show_always = true;
        style_user = "green";
        style_root = "red";
        format = "[ $user](fg:$style bg:black bold)";
        disabled = false;
      };
      hostname = {
        ssh_only = false;
        show_always = true;
        style = "fg:white bg:black bold";
        format = "[@$hostname ]($style)";
        disabled = false;
      };
      directory = {
        style = "bg:blue dimmed fg:black";
        disabled = false;
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
      };
      git_branch = {
        symbol = "";
        style = "bg:yellow fg:black";
        format = "[ $symbol $branch]($style)";
      };
      git_status = {
        style = "yellow";
        format = "[ $all_status $ahead_behind](fg:black bg:$style)[ ](fg:$style bg:black)";
      };
    };
  };

  programs.zsh = {
    enable = true;
  };

  programs.niri.settings = {
    binds = {
      "Mod+T".action.spawn = "footclient";
    };

    spawn-at-startup = [
      { sh = "foot --server"; }
      # { sh = "eval $(starship init zsh)"; }
    ];
  };
}
