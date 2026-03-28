{
  inputs = {
    agenix.url = "github:ryantm/agenix";
    niri.url = "github:sodiboo/niri-flake";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";
    flatpaks.url = "github:in-a-dil-emma/declarative-flatpak/latest";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs =
    {
      agenix,
      flatpaks,
      home-manager,
      niri,
      nixpkgs,
      nixpkgs-unstable,
      stylix,
      zen-browser,
      ...
    }:
    {
      nixosConfigurations."workstation" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
        };
        modules = [
          ./configuration.nix
          niri.nixosModules.niri
          stylix.nixosModules.stylix
          agenix.nixosModules.default
          flatpaks.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."piergabory" = {
                home = {
                  username = "piergabory";
                  homeDirectory = "/home/piergabory";
                };
                imports = [
                  ./home
                  zen-browser.homeModules.beta
                  agenix.homeManagerModules.default
                ];
              };
              users.root = {
                home = {
                  username = "root";
                  homeDirectory = "/root";
                };
                imports = [
                  ./home
                  zen-browser.homeModules.beta
                  agenix.homeManagerModules.default
                ];
              };
            };
          }
        ];
      };
    };
}
