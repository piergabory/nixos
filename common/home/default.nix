{
  ageSecrets,
  inputs,
  hostHomeModules ? [ ],
  ...
}:

{
  age.secrets = {
    icloud-mail = ageSecrets.icloud-mail;
    icloud-dav = ageSecrets.icloud-dav;
    radicale-dav = ageSecrets.radicale-dav;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
    };
    users."piergabory" = {
      home = {
        username = "piergabory";
        homeDirectory = "/home/piergabory";
      };
      imports = [
        inputs.zen-browser.homeModules.beta
        inputs.agenix.homeManagerModules.default
        ./configuration.nix
      ]
      ++ hostHomeModules;
    };
    users."root" = {
      home = {
        username = "root";
        homeDirectory = "/root";
      };
      imports = [
        inputs.zen-browser.homeModules.beta
        inputs.agenix.homeManagerModules.default
        ./configuration.nix
      ]
      ++ hostHomeModules;
    };
  };
}
