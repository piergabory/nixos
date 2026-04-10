{
  inputs = {
    agenix.url = "github:ryantm/agenix";
    niri.url = "github:sodiboo/niri-flake";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      agenix,
      home-manager,
      niri,
      nixpkgs,
      nixpkgs-unstable,
      nixos-hardware,
      stylix,
      zen-browser,
      ...
    }:
    {
      nixosConfigurations."thinkpad" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
        };
        modules = [
          ./configuration.nix
          niri.nixosModules.niri
          stylix.nixosModules.stylix
          agenix.nixosModules.default
          nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
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
