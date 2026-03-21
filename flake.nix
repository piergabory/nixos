{
  inputs = {
    agenix.url = "github:ryantm/agenix";
    niri.url = "github:sodiboo/niri-flake";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    
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
        # IMPORTANT: To ensure compatibility with the latest Firefox version, use nixpkgs-unstable.
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs =
    {
      agenix,
      home-manager,
      niri,
      nixpkgs,
      stylix,
      zen-browser,
      ...
    }:
    {
      nixosConfigurations."workstation" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          niri.nixosModules.niri
          stylix.nixosModules.stylix
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."piergabory" = import ./home;
            };
          }
          (
            { ... }:
            {
              home-manager.users.piergabory = {
                imports = [
                  zen-browser.homeModules.beta
                  agenix.homeManagerModules.default
                ];
              };
            }
          )
        ];
      };
    };
}
