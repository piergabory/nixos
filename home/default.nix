{
  inputs,
  ...
}:

{
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
      ];
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
      ];
    };
  };
}
