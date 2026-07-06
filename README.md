# Pierre's NixOS Homelab

This repository contains the NixOS flake that runs my personal machines and home lab.
It is public for inspiration and reference, not because it is meant to be reused as-is.

Expect real configuration shaped by my hardware, domains, network, habits, and tradeoffs.
Some parts may be useful patterns; other parts will only make sense in my environment.

## Hosts

- `workstation`: my main desktop and primary home server.
- `thinkpad`: my laptop and client machine.

Both hosts share common NixOS and Home Manager modules, then add host-specific hardware,
services, and user overrides.

## What Is Inside

- Flake-based NixOS configurations on `nixos-unstable`.
- Shared desktop and user environment managed with Home Manager.
- Self-hosted services behind nginx, ACME TLS, and selected Authelia SSO.
- Media, photos, sync, DNS, budgeting, backups, and other personal services.
- Encrypted secrets managed with agenix.
- Wayland, theming, editor, browser, terminal, and desktop configuration.

## Repository Layout

- `flake.nix`: inputs and host outputs.
- `common/`: shared system and Home Manager configuration.
- `hosts/workstation/`: desktop and home-server configuration.
- `hosts/thinkpad/`: laptop-specific configuration.
- `secrets/`: agenix declarations and encrypted secret files.
- `assets/`: static files consumed by modules.

## Borrowing Ideas

Copy concepts, not whole files.
Check every user, path, domain, port, mount point, firewall rule, and secret reference.
Do not expose services publicly until you understand their authentication model.
Replace all secrets with your own and never commit plaintext credentials.

If this helps you design your own NixOS homelab, it has done its job.
