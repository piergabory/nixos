{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.11";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
    };

    zen-browser = {
       url = "github:0xc000022070/zen-browser-flake";
       inputs = {
         # IMPORTANT: To ensure compatibility with the latest Firefox version, use nixpkgs-unstable.
         nixpkgs.follows = "nixpkgs";
         home-manager.follows = "home-manager";
       };
     };
  };

  outputs = { nixpkgs, home-manager, zen-browser, niri, ... } @inputs: {
    nixosConfigurations."workstation" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix

        ({config, pkgs, ...}: {
          home-manager.users.piergabory = {
            imports = [
              zen-browser.homeModules.beta
            ];
          };
        })

        home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users."piergabory" = import ./home;
          };
        }

        niri.nixosModules.niri
      ];
    };
  };
}
