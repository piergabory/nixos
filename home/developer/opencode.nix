{
  config,
  lib,
  pkgs,
  isDroid ? false,
  ...
}:

{
  imports = [ ./hunk ];

  home.packages = with pkgs; lib.optionals (!isDroid) [ opencode-desktop ];

  # This directory precedes the Nix profile in the phone's PATH. Home Manager
  # backs up the old unmanaged binary before linking the managed executable.
  home.file = lib.mkIf isDroid {
    ".local/bin/opencode".source = "${config.programs.opencode.package}/bin/opencode";
  };

  programs.opencode = {
    enable = true;
    package = lib.mkIf isDroid (pkgs.callPackage ../../packages/opencode-droid.nix { });
    # The pinned Stylix target still selects its theme through the OpenCode 1
    # option. Keep its theme file, but select it through cli.json on Droid.
    tui = lib.mkIf isDroid (lib.mkForce { });
    cli.theme = lib.mkIf isDroid "stylix";
    settings = {
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
