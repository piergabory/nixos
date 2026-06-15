{
  description = "NixOS Configurations for Pierre's computer hardware.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixarr = {
      url = "github:nix-media-server/nixarr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
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
    inputs@{
      agenix,
      home-manager,
      niri,
      nixpkgs,
      nixarr,
      nixos-hardware,
      nixvim,
      stylix,
      ...
    }:
    let
      ageSecrets = import ./secrets;

      commonModules = [
        ./common/home
        niri.nixosModules.niri
        stylix.nixosModules.stylix
        agenix.nixosModules.default
        nixvim.nixosModules.nixvim
        ({ inputs, ... }: {
          lib.nixvim = inputs.nixvim.lib.nixvim;
        })
        home-manager.nixosModules.home-manager
      ];
    in
    {
      nixosConfigurations."workstation" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = commonModules ++ [
          nixarr.nixosModules.default
          ./hosts/workstation
        ];
        specialArgs = {
          inherit inputs ageSecrets;
          hostHomeModules = [ ./hosts/workstation/home ];
        };
      };

      nixosConfigurations."thinkpad" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = commonModules ++ [
          ./hosts/thinkpad
          nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
        ];
        specialArgs = {
          inherit inputs ageSecrets;
          hostHomeModules = [ ./hosts/thinkpad/home ];
        };
      };
    };
}
