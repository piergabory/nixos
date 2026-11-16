{ lib, pkgs, ... }:

let
  launcher =
    pkgs.runCommand "hunk-review-open"
      {
        nativeBuildInputs = [
          pkgs.makeWrapper
          pkgs.python3
        ];
      }
      ''
        PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s ${./.} -p 'test_*.py'
        mkdir -p "$out/bin"
        makeWrapper ${pkgs.python3}/bin/python3 "$out/bin/hunk-review-open" \
          --add-flags ${./open_review.py} \
          --prefix PATH : ${
            lib.makeBinPath [
              pkgs.git
              pkgs.hunk
              pkgs.zellij
            ]
          }
      '';
in
{
  home.packages = [
    pkgs.hunk
    launcher
  ];

  programs.opencode.settings.instructions = [ "${./review-guidance.md}" ];

  xdg.configFile = {
    "opencode/skills/hunk-review/SKILL.md".source = ./SKILL.md;
    "opencode/skills/hunk-review/references/upstream.md".source =
      "${pkgs.hunk}/skills/hunk-review/SKILL.md";
  };
}
