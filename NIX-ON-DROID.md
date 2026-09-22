# Nix-on-Droid Recommendations

The Galaxy Z Fold 8 is a strong target for a portable terminal and development
environment. Its aarch64 platform is the primary architecture supported by
Nix-on-Droid, and most command-line packages in nixpkgs are available for it.

Nix-on-Droid is not NixOS running on Android. It operates through `proot`
without root access, systemd, direct hardware management, or normal Linux
desktop integration. Command-line applications and Home Manager are therefore
the best fit. Android should remain responsible for graphical applications,
notifications, media playback, storage synchronization, and persistent
background work.

## Current configuration

The current target in `configurations/linux/droid/default.nix` installs a useful
baseline collection:

- `fastfetch`
- `btop`
- Vim
- Git and Lazygit
- process and hostname utilities
- manual pages
- compression and archive utilities
- GNU grep and diffutils
- GnuPG

Before deploying it, make the following corrections:

1. Set `system.stateVersion = "24.05"`. The option is currently required but
   unset, and the pinned Nix-on-Droid revision only accepts state versions up
   to `24.05`.
2. Replace the deprecated `utillinux` package name with `util-linux`.
3. Explicitly enable flakes:

   ```nix
   nix.extraOptions = ''
     experimental-features = nix-command flakes
   '';
   ```

4. If the current repository Home Manager modules are used, pass the matching
   Home Manager source to `nixOnDroidConfiguration`:

   ```nix
   home-manager-path = inputs.home-manager.outPath;
   ```

   Without this, Nix-on-Droid uses its own internally pinned Home Manager
   revision from 2024. That revision does not match this repository's current
   Home Manager input or `home.stateVersion = "26.05"`.

The full activation package cannot currently be evaluated directly on the
x86_64 workstation because Nix-on-Droid determines the Android application's
UID and GID using an aarch64 derivation. Normal switching should be performed
on the phone.

## Recommended Android integration

Nix-on-Droid provides Android-specific commands that are more useful than many
additional generic packages:

```nix
android-integration = {
  am.enable = true;
  termux-open.enable = true;
  termux-open-url.enable = true;
  termux-setup-storage.enable = true;
  termux-reload-settings.enable = true;
  termux-wake-lock.enable = true;
  termux-wake-unlock.enable = true;
  xdg-open.enable = true;
};
```

These options provide:

- Access to Android shared storage through links under `~/storage`.
- Opening files and URLs in Android applications.
- An `xdg-open` command backed by Android.
- Wake-lock control for long builds or interactive synchronization.
- Reloading terminal settings without restarting every terminal session.
- Limited access to Android's activity manager.

Leave `android-integration.unsupported.enable` disabled unless a particular
unsupported command is deliberately being tested.

The native user and shell can be configured with:

```nix
user = {
  userName = "piergabory";
  shell = "${pkgs.zsh}/bin/zsh";
};

time.timeZone = "Europe/Paris";
```

The existing `modules/shell.nix` cannot be imported directly because it uses
NixOS options such as `programs.zsh` and `users.defaultUserShell`. Its behavior
should be recreated with Home Manager's Zsh module and Nix-on-Droid's
`user.shell` option.

Nix-on-Droid can also declaratively configure the terminal font and its
sixteen-color palette through `terminal.font` and `terminal.colors`. This is
the appropriate replacement for importing the NixOS Stylix module.

## Home Manager structure

Do not import `home/default.nix` unchanged. It unconditionally enables accounts,
desktop programs, the full development profile, music services, XDG desktop
integration, and Stylix.

Create a dedicated mobile profile, such as `home/droid.nix`, that imports only
the portable modules:

```nix
{
  imports = [
    ./developer/git.nix
    ./developer/nixvim
    ./programs/ssh.nix
  ];

  home.stateVersion = "26.05";
}
```

Then connect it from the Nix-on-Droid configuration:

```nix
home-manager = {
  config = ../../../home/droid.nix;
  backupFileExtension = "home-manager-backup";
  useGlobalPkgs = true;
  extraSpecialArgs = {
    inherit inputs;
  };
};
```

The precise relative path depends on whether this block remains in
`configurations/linux/droid/default.nix`.

## Strong candidates

### Git and SSH

`home/developer/git.nix` is suitable as written. Git and Lazygit are especially
useful on the Fold's larger display.

`home/programs/ssh.nix` is also suitable. It configures an SSH client and does
not depend on systemd. This makes the phone a practical administrative terminal
for the workstation, offsite host, and home server.

The NixOS `modules/openssh.nix` module cannot be used. An SSH server can
technically be run manually on an unprivileged port, but it will only be
reliable while the application remains alive and may require a wake lock and an
Android battery-optimization exemption.

### Terminal editors

Both Helix and Nixvim are realistic.

The existing Nixvim configuration can mostly be reused, including:

- Treesitter.
- Telescope.
- Git integrations.
- LSP support.
- Formatting.
- Completion.
- Vimwiki.
- Embedded terminal support.

Recommended mobile adjustments:

- Disable `image.nvim`; common terminal image protocols are unlikely to work in
  the Nix-on-Droid terminal.
- Do not assume `clipboard.register = "unnamedplus"` can reach the Android
  clipboard. It requires a compatible clipboard provider or a custom Android
  bridge.
- Consider a reduced plugin profile to improve startup time and reduce closure
  size.
- Keep Helix installed as a lightweight fallback.

### Development tools

The development packages checked in the current nixpkgs input are available for
aarch64. Practical groups include:

- Nix: `nixd`, `nil`, `nixfmt`, `nix-tree`, `nix-output-monitor`, and
  `nix-index`.
- Shell and scripting: `shellcheck`, `shfmt`, Python, Lua, YAML, JSON, and Vim
  language servers.
- Web development: Node.js, Prettier, TypeScript, HTML, and CSS tooling.
- Rust: Cargo, Rustc, Rustfmt, Clippy, and rust-analyzer.

These should be selected rather than enabled wholesale. Language servers and
their dependency closures consume substantial storage, while compilation can
cause thermal throttling and significant battery drain.

Nix and scripting tools are the best default. Web and Rust tooling make sense
when the phone will regularly be used with a physical keyboard or DeX.

### AI command-line tools

GitHub Copilot CLI and OpenCode are available for aarch64 and are reasonable
terminal applications. Authentication flows should work more smoothly after
enabling `termux-open-url`.

`programs.tokscale` should not be enabled unchanged. Its wrapper runs Bun
through `steam-run` on every Linux platform. That wrapper is unnecessary for a
native Bun executable and is a poor fit for ARM Android. Restrict `steam-run`
to x86 Linux or run Bun directly on Nix-on-Droid.

### General utilities

The following are good additions to the existing package set:

- `ripgrep`
- `fd`
- `jq`
- `curl`
- `wget`
- `rsync`
- `tree`
- `file`
- `which`
- `tmux`
- `mosh`, if roaming SSH sessions are useful

Avoid installing multiple large tools with overlapping purposes unless they
will actually be used; phone storage and Nix store growth matter more than on a
workstation.

## Features that require extraction or adjustment

### Calendar and contacts

The CLI portions of `home/accounts/default.nix` can be useful:

- Vdirsyncer
- Khal
- Khard

The module cannot be imported unchanged because it also configures Thunderbird.
Extract the CalDAV/CardDAV and terminal client settings into a separate module.

There is no systemd user service, so automatic periodic synchronization will
not behave like it does on NixOS. Manual synchronization is reliable; Android
automation is possible but should not be treated as an always-running Linux
service.

The current `dav.age` secret is encrypted only for the existing root and
workstation identities. The phone needs its own age identity and recipient
before it can decrypt that secret. The private identity should remain inside
the Nix-on-Droid application's private storage rather than shared Android
storage.

### Music tools

`home/music.nix` cannot be used as written because its MPD output targets
PipeWire. Nix-on-Droid does not provide the workstation's PipeWire environment.

Beets can be extracted into a standalone module for organizing files. Khal,
Khard, Beets, and other database-oriented CLI applications are all viable when
their data lives in paths accessible to the Nix-on-Droid application.

Android applications remain the appropriate choice for actual playback.

### Styling

Do not import `modules/stylix.nix`, since it selects the NixOS Stylix module and
configures desktop fonts and applications.

Possible styling layers are:

1. Nix-on-Droid's `terminal.font` and `terminal.colors`.
2. Home Manager Stylix targets for supported terminal applications.
3. Explicit themes in Zsh, Nixvim, Helix, Lazygit, and other CLI programs.

The existing Fira Code Nerd Font and Gruvbox palette are sensible choices for
the terminal.

## Prefer native Android applications

### Syncthing

Use the native Android Syncthing application rather than
`modules/syncthing/default.nix`.

The repository already defines `fold8` as a Syncthing device. A native client
handles Android storage permissions, notifications, networking changes, and
battery restrictions better than a daemon running under `proot`.

After running `termux-setup-storage`, Nix-on-Droid commands can operate on files
that the Android Syncthing application places in shared storage. Paths in
terminal tools should use the generated `~/storage` links instead of assuming
normal Linux mount points.

### Obsidian

Use the Android Obsidian application. The Nix desktop package cannot configure
or replace the Android app because each application has a separate Android
sandbox.

Continue synchronizing the `Notes` vault through the native Syncthing client.
The existing mobile toolbar and ignore-pattern decisions remain relevant to
the vault, but the Android Obsidian settings themselves should be managed by
the Android app or synchronized files rather than a Home Manager desktop
module.

### Other graphical programs

Do not include the graphical applications from `home/programs/default.nix`:

- Zen Browser
- Thunderbird
- Obsidian desktop
- Foot
- Vicinae
- ZapZap
- Beeper
- Signal Desktop
- Slack
- Telegram Desktop
- Dolphin
- GIMP
- Darktable
- MPV and Qt Transmission as desktop applications

Although some packages may evaluate for aarch64, Nix-on-Droid does not provide
a normal Wayland or X11 desktop session. Running a separate display server is
possible as an experiment, but it is not a realistic replacement for native
Android applications.

## Modules to exclude

Do not import the repository's top-level `modules/default.nix` into the
Nix-on-Droid target. It is a NixOS module tree and includes system-level
functionality that does not exist under Android.

Exclude:

- All homelab modules.
- Desktop, Niri, Waybar, and graphical application modules.
- Audio and Bluetooth configuration.
- NixOS OpenSSH service configuration.
- NixOS Syncthing service configuration.
- Auto-upgrade services and timers.
- Photography applications.
- Offsite backup services.
- NetworkManager and bootloader configuration.
- NixOS user, locale, console, and X server options.
- The existing XDG module's GTK bookmarks and MIME associations.

Nix-on-Droid has no equivalents for most of these because Android controls the
kernel, boot process, network stack, devices, and application lifecycle.

## Suggested scope

A balanced Fold 8 profile would include:

1. Nix-on-Droid Android integration and terminal styling.
2. Zsh with Powerlevel10k.
3. Git, Lazygit, SSH, GnuPG, and age.
4. Nixvim or Helix, ideally with a reduced mobile plugin set.
5. Nix and shell development tools.
6. Optional web or Rust toolchains when there is a concrete use for them.
7. GitHub Copilot CLI or OpenCode if desired.
8. General Unix tools such as ripgrep, fd, jq, curl, rsync, and tmux.

Android should provide:

- Syncthing.
- Obsidian.
- Browsers and messaging.
- Music and video playback.
- Long-running background synchronization.
- Notifications and hardware integration.

This split preserves the strongest parts of the existing configuration—a
consistent shell, editor, Git workflow, SSH access, and development tools—while
avoiding attempts to reproduce NixOS services inside Android's constrained
application environment.
