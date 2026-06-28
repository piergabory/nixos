# Agent Notes

## Project Goal

This repository is a NixOS flake for Pierre's machines. The main goal is to self-host personal IT services declaratively while also managing desktop/laptop user environments with Home Manager.

The `workstation` host is both a desktop and the primary home server. The `thinkpad` host is a client/laptop that shares the common desktop configuration and connects back to home-server services.

## Repository Layout

- `flake.nix` defines inputs and the two NixOS configurations: `workstation` and `thinkpad`.
- `common/` contains configuration shared by all hosts.
- `common/modules/` contains shared NixOS modules such as users, shell, Stylix, Niri, Steam, scanner support, and Nixvim.
- `common/services/` contains shared system services such as PipeWire and OpenSSH.
- `common/home/` contains shared Home Manager configuration for the `piergabory` and `root` users.
- `common/home/programs/` contains user program configuration such as browser, compositor, Waybar, Git, terminal, editor, file manager, and related desktop programs.
- `common/home/services/` contains user services such as MPD and Gammastep.
- `common/home/accounts/` contains Home Manager account declarations for email, calendar, contacts, and vdirsyncer-based sync.
- `hosts/workstation/` contains host-specific NixOS configuration for the workstation/home server.
- `hosts/workstation/modules/` contains workstation-specific hardware, boot, networking, graphics, swap, and localization modules.
- `hosts/workstation/services/` contains the self-hosted service stack.
- `hosts/workstation/home/` contains workstation-specific Home Manager overrides.
- `hosts/thinkpad/` contains host-specific NixOS configuration for the ThinkPad.
- `hosts/thinkpad/modules/` contains ThinkPad-specific boot, networking, and localization modules.
- `hosts/thinkpad/services/` contains ThinkPad-specific services and home-server mounts.
- `hosts/thinkpad/home/` contains ThinkPad-specific Home Manager overrides.
- `secrets/` contains age secret declarations and encrypted secret files.

## Flake Structure

Shared modules are collected in `commonModules` in `flake.nix`. Both hosts import these shared modules, then add their host-specific module tree.

Important flake inputs include:

- `nixpkgs` on `nixos-unstable`.
- `home-manager` for user configuration.
- `agenix` for encrypted secrets.
- `stylix` for theming.
- `niri` for the Wayland compositor.
- `nixvim` for Neovim configuration.
- `nixarr` for the media-server stack on `workstation`.
- `zen-browser` and `firefox-addons` for browser configuration.
- `nixos-hardware` for ThinkPad hardware support.

Host-specific Home Manager modules are passed through `hostHomeModules` in `specialArgs`.

## Secrets

Secrets are managed with agenix.

- `secrets/secrets.nix` maps encrypted `.age` files to the public keys that may decrypt them.
- `secrets/default.nix` imports those encrypted secrets into a reusable `ageSecrets` attribute set.
- `flake.nix` imports `./secrets` as `ageSecrets` and passes it through `specialArgs`.
- NixOS modules usually expose secrets with `age.secrets.<name> = ageSecrets.<name>;`.
- Home Manager modules access OS-level age secret paths through `osConfig.age.secrets.<name>.path` where needed.

Do not put plaintext secrets in Nix files, comments, commit messages, documentation, tool calls, or chat messages. Agents must never see, request, generate, edit, decrypt, print, or otherwise handle secret values.

If a change requires a new or updated secret, ask Pierre to create or update the relevant age secret file himself. Then stop and wait for Pierre's explicit signal to continue before wiring the secret path into the configuration.

Agents may only reference secret file names and age secret paths after Pierre confirms the secret file exists. The secret value itself must remain entirely user-managed.

## Workstation Role

The workstation is the primary self-hosting machine. Its service imports are listed in `hosts/workstation/services/default.nix`.

The workstation currently includes services for:

- Reverse proxy and TLS through nginx and ACME.
- Dashboarding through Glance.
- Photos through Immich.
- Media serving and automation through Jellyfin and nixarr.
- Password management through Vaultwarden.
- Budgeting through Actual.
- Calendar and contacts through Radicale.
- File sync through Syncthing.
- File sharing through Samba.
- DNS/adblocking through Pi-hole.
- Smart home through Home Assistant, Matter server, and Home Assistant Matter Hub.
- Geolocation tracking through Dawarich.
- Single-user social hosting through Mastodon.
- Minecraft server hosting.
- Backups through restic and rsync jobs.
- RAID support through mdadm.
- Local mail support through Postfix.

Most externally reachable web services are exposed through nginx virtual hosts under `piergabory.net` subdomains.

## ThinkPad Role

The ThinkPad is a client machine using the common desktop/Home Manager stack with laptop-specific modules and services.

It mounts home-server Samba shares under `/mnt/home-server/` and has ThinkPad-specific services such as fingerprint support, laptop power management, Syncthing, and logind behavior.

## Home Manager

Home Manager is configured in `common/home/default.nix` for both `piergabory` and `root`.

Most user-facing configuration should be scoped carefully. If a setting is only intended for the normal user, guard it with `lib.mkIf (config.home.username == "piergabory")` so it does not affect root.

Home Manager currently manages desktop apps, browser configuration, Niri, Waybar, Git, editor tooling, terminal configuration, account sync, XDG defaults, MPD, Gammastep, packages, and host-specific user overrides.

Prefer first-class Home Manager modules when available. Use `home.file` or `xdg.configFile` when there is no suitable module or when direct file generation is clearer.

## Editing Guidelines

- Keep changes small and declarative.
- Prefer adding or changing focused modules near the relevant service or host.
- Avoid mixing unrelated service changes in one edit.
- Preserve host separation: shared behavior belongs in `common/`; host-only behavior belongs under `hosts/<host>/`.
- When adding secrets, update the agenix secret mapping and consume secret paths rather than embedding values.
- When changing service exposure, check nginx, firewall, and local bind addresses together.
- When adding backups for a stateful service, follow the existing restic pattern and reuse `config.piergabory.backups`.
- Run `nix flake check` after meaningful configuration changes when feasible.
