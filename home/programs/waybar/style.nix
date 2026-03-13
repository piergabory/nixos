{ lib, ... }:
{
  programs.waybar.style = lib.mkAfter ''    
    * {
        font-family: "JetBrains Mono Nerd Font", "Font Awesome 6 Free";
        font-size: 13px;
        background-color: transparent;
        border-color: transparent;
        outline-color: transparent;
    }
  
    button:not(:active), button:not(:selected), button:not(:focused) {
        opacity: 0.75;
    }
    '';
}
