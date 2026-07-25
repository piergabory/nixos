{
  description = "NixOS Configurations for Pierre's computer hardware.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";

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

  outputs = inputs@{ nixpkgs, ... }: {
    nixosConfigurations = {
      workstation = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configurations/linux/workstation
        ];
        specialArgs = {
          inherit inputs;
          useDarwinModule = false;
        };
      };

      thinkpad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configurations/linux/thinkpad
        ];
        specialArgs = {
          inherit inputs;
          useDarwinModule = false;
        };
      };

      offsite = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configurations/linux/offline
        ];
        specialArgs = {
          inherit inputs;
          useDarwinModule = false;
        };
      };
    };

    darwinConfigurations.macbook = inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./configurations/darwin/work-macbook.nix
      ];
      specialArgs = {
        inherit inputs;
        useDarwinModule = true;
      };
    };
  };
}
