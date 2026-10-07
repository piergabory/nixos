{ inputs, lib, pkgs, ... }:

{
  programs.opencode = {
    enable = true;
    package = inputs.opencode-v2.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
    settings = {
      mcp = {
        atlassian = {
          type = "remote";
          url = "https://mcp.atlassian.com/v1/mcp/authv2";
        };
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        xcode = {
          type = "local";
          command = [
            "xcrun"
            "mcpbridge"
          ];
        };
      };

      permissions = [
        {
          action = "external_directory";
          resource = "~/Developer/*";
          effect = "allow";
        }
        {
          action = "read";
          resource = "~/Developer";
          effect = "allow";
        }
        {
          action = "read";
          resource = "~/Developer/*";
          effect = "allow";
        }
        {
          action = "edit";
          resource = "~/Developer/*";
          effect = "allow";
        }

        {
          action = "external_directory";
          resource = "~/.config/nix-darwin/*";
          effect = "allow";
        }
        {
          action = "read";
          resource = "~/.config/nix-darwin";
          effect = "allow";
        }
        {
          action = "read";
          resource = "~/.config/nix-darwin/*";
          effect = "allow";
        }
        {
          action = "edit";
          resource = "~/.config/nix-darwin/*";
          effect = "ask";
        }

        {
          action = "external_directory";
          resource = "~/.config/nix/*";
          effect = "allow";
        }
        {
          action = "read";
          resource = "~/.config/nix";
          effect = "allow";
        }
        {
          action = "read";
          resource = "~/.config/nix/*";
          effect = "allow";
        }
        {
          action = "edit";
          resource = "~/.config/nix/*";
          effect = "ask";
        }

        {
          action = "external_directory";
          resource = "~/.config/nixpkgs/*";
          effect = "allow";
        }
        {
          action = "read";
          resource = "~/.config/nixpkgs";
          effect = "allow";
        }
        {
          action = "read";
          resource = "~/.config/nixpkgs/*";
          effect = "allow";
        }
        {
          action = "edit";
          resource = "~/.config/nixpkgs/*";
          effect = "ask";
        }

        {
          action = "external_directory";
          resource = "~/.nixpkgs/*";
          effect = "allow";
        }
        {
          action = "read";
          resource = "~/.nixpkgs";
          effect = "allow";
        }
        {
          action = "read";
          resource = "~/.nixpkgs/*";
          effect = "allow";
        }
        {
          action = "edit";
          resource = "~/.nixpkgs/*";
          effect = "ask";
        }

        {
          action = "external_directory";
          resource = "/etc/nixos/*";
          effect = "allow";
        }
        {
          action = "read";
          resource = "/etc/nixos";
          effect = "allow";
        }
        {
          action = "read";
          resource = "/etc/nixos/*";
          effect = "allow";
        }
        {
          action = "edit";
          resource = "/etc/nixos/*";
          effect = "ask";
        }

        {
          action = "external_directory";
          resource = "/etc/nix/*";
          effect = "allow";
        }
        {
          action = "read";
          resource = "/etc/nix";
          effect = "allow";
        }
        {
          action = "read";
          resource = "/etc/nix/*";
          effect = "allow";
        }
        {
          action = "edit";
          resource = "/etc/nix/*";
          effect = "ask";
        }

        {
          action = "external_directory";
          resource = "/nix/*";
          effect = "allow";
        }
        {
          action = "read";
          resource = "/nix";
          effect = "allow";
        }
        {
          action = "read";
          resource = "/nix/*";
          effect = "allow";
        }
        {
          action = "edit";
          resource = "/nix/*";
          effect = "deny";
        }
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
        {
          action = "external_directory";
          resource = "~/Library/Developer/Xcode/DerivedData/*";
          effect = "allow";
        }
        {
          action = "read";
          resource = "~/Library/Developer/Xcode/DerivedData";
          effect = "allow";
        }
        {
          action = "read";
          resource = "~/Library/Developer/Xcode/DerivedData/*";
          effect = "allow";
        }
        {
          action = "edit";
          resource = "~/Library/Developer/Xcode/DerivedData/*";
          effect = "deny";
        }
      ];
    };
  };
}
