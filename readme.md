# Workstation NixOS Configuration

This repository contains the NixOS configuration running on my Mac Pro (2013) computer.
The old trash can has tricky dual GPUs and a power hungry CPU, but i'm a sucker for that design.

May this be useful for someone trying to run NixOS on the same computer, or anyone intereseted in using Niri with NixOS.

## Structure

- `hardware-configuration.nix` generated hardware configuration
- `flake.nix` Home Manager, Niri, Zen Browser
- `configuration.nix` Configuration root
- home: Home manager configuration
  - config: Dot file management
  - environment: theme, fonts, session variables
  - programs: GUI/TUI desktop applications
  - services: user services (ssh, music deamon)
- modules: 
  - displaymanager: authentication lock screen (ly)
  - localisation: language, region and time settings
  - networking
  - users
- services
- system: hardware specific configuration
  - boot: fix issues with Mac Pro hardware
  - graphics: fix issues with Mac Pro D300 graphics
  - nas: mount local drives.
