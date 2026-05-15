{ ... }:

{
  boot.swraid = {
    enable = true;
    mdadmConf = ''
      MAILADDR mail@piergabory.net
    '';
  };
}
