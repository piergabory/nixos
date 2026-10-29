{
  pkgs,
  name,
  settings,
}:

let
  source = pkgs.writeText "${name}.json" (builtins.toJSON settings);
  preferences = pkgs.runCommand "${name}.plist" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    PYTHONDONTWRITEBYTECODE=1 python -m unittest discover -s ${./.}
    python ${./preferences.py} render ${source} "$out"
  '';
in
pkgs.writeShellScript "apply-${name}" ''
  exec ${pkgs.python3}/bin/python ${./preferences.py} apply ${preferences} "$@"
''
