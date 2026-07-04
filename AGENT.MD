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

### Authelia secrets

Authelia consumes several agenix secrets (see `secrets/default.nix`), all owned by the `authelia-main` service user with mode `0400`:

- `authelia-jwt`, `authelia-session`, `authelia-storage-key`, `authelia-oidc-hmac`: random strings.
- `authelia-oidc-jwks`: an RSA private key PEM (OIDC token signing).
- `authelia-users`: the user database YAML with argon2id password hashes. To change the `auth.pierr.re` login password, regenerate the hash with `authelia crypto hash generate argon2`, update this secret, `nixos-rebuild switch`, then `systemctl restart authelia-main.service` (because `watch = false`).
- `authelia-oidc-clients`: OIDC client registrations with pbkdf2-hashed client secrets. Each client's plaintext secret goes into the consuming app (env-file secret or the app's admin UI); only the hash lives here.

### Human credentials vs machine secrets

Distinguish two kinds of secret when deciding where a value belongs:

- Human credentials (values Pierre types into a login prompt): Authelia login password, Radicale/DAV passwords, Samba/Syncthing GUI passwords, iCloud app-specific passwords, site logins. These are appropriate to store in Vaultwarden for personal recall. Storing the Authelia password in Vaultwarden is safe specifically because Vaultwarden is intentionally excluded from Authelia SSO; keep it that way to avoid a circular unlock dependency.
- Machine secrets (values one service presents to another): API keys, access tokens (e.g. `home-assistant-token`), signing keys (`authelia-oidc-jwks`), random Authelia internals, and all password/verifier hashes (`authelia-users`, `authelia-oidc-clients`). agenix is the single source of truth for these; do not duplicate them into Vaultwarden.
- `restic-password` is a machine secret but should also be kept in a second location independent of the workstation, or the backups are unrecoverable if the machine is lost. This relates to the open item that backups are currently on-host only.

## Workstation Role

The workstation is the primary self-hosting machine. Its service imports are listed in `hosts/workstation/services/default.nix`.

The workstation currently includes services for:

- Reverse proxy and TLS through nginx and ACME.
- Central authentication and SSO through Authelia (see the Authentication and SSO section).
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
- Flight tracking through AirTrail.
- Single-user social hosting through Mastodon.
- Minecraft server hosting.
- Backups through restic and rsync jobs.
- RAID support through mdadm.
- Local mail support through Postfix.

Most externally reachable web services are exposed through nginx virtual hosts. Only ports 80, 443, and 22 are forwarded from the router; there is no VPN overlay, so nginx + Authelia is the primary protection for web services.

## Domains

Two domains are live and both resolve to the workstation: the legacy `piergabory.net` and the newer `pierr.re`. They coexist and both continue to work. Prefer `pierr.re` for any new or migrated resources. When a service is placed behind Authelia SSO it must be served under the same parent domain as the Authelia session cookie (`pierr.re`), so SSO-protected vhosts use `*.pierr.re` (existing `piergabory.net` vhosts may remain as unprotected aliases). Email identities (ACME, git, Postfix, mdadm `MAILADDR`, Mastodon `fromAddress`) still use `mail@piergabory.net` and were intentionally not migrated.

## Authentication and SSO (Authelia)

Central SSO is provided by Authelia, defined in `hosts/workstation/services/authelia.nix` (instance `main`, service user `authelia-main`).

- Portal is served at `https://auth.pierr.re`. Authelia listens on `127.0.0.1:9092` (not the default `9091`, which is taken by `transmission-daemon` from the nixarr stack).
- File-based user backend with argon2id hashes; `password_reset.disable = true` and `watch = false` (Authelia must be restarted to pick up a changed user database). TOTP/WebAuthn MFA and brute-force `regulation` are enabled. `access_control` is default-deny.
- The module exposes two read-only nginx snippets consumed by protected vhosts: `config.piergabory.authelia.internalAuthLocation` (server-level) and `config.piergabory.authelia.forwardAuthConfig` (per-location). These use the nginx `auth_request` flow against Authelia's `AuthRequest` endpoint `/api/authz/auth-request` (returns 401, converted by `error_page 401 =302` to a portal redirect). Do NOT use the `/api/authz/forward-auth` endpoint here: it returns 302, which nginx `auth_request` rejects as an unexpected status (HTTP 500).
- Authelia is also an OIDC provider. OIDC clients are declared in the `authelia-oidc-clients` agenix secret (a settings fragment holding pbkdf2-hashed client secrets), loaded via `settingsFiles`. The OIDC provider is always enabled and requires at least one valid client, so this secret must contain real hashes or Authelia will not start.

Per-service auth model:

- Forward-auth (browser-only apps, gated by Authelia + MFA): Glance (`dash.pierr.re`), Syncthing GUI (`sync.pierr.re`).
- Native OIDC clients (app keeps its own session for mobile/native clients): intended for Immich, Actual, Mastodon, and similar. Mastodon and Actual take OIDC via env-file secrets (`mastodon-oidc-env`, `actual-oidc-env`); Immich/Jellyfin/Home Assistant configure OIDC in their own admin UI.
- Intentionally NOT behind SSO: Vaultwarden (keep out of SSO to avoid a password-manager lockout / circular dependency) and Radicale (CalDAV/CardDAV clients only support HTTP Basic auth). Home Assistant and Immich must use native OIDC or native auth rather than forward-auth because they have mobile apps.

## Workstation Service Ports

Local reverse-proxy ports used by `hosts/workstation/services`. Public hosts marked "SSO" are gated by Authelia forward-auth; others use the app's native auth or OIDC. Services proxied by nginx bind to loopback and must NOT open their port on the firewall (`openFirewall` is intentionally off for these).

| Service | Public host | Local target | Auth |
| --- | --- | --- | --- |
| Authelia | `auth.pierr.re` | `127.0.0.1:9092` | portal |
| Actual Budget | `budget.piergabory.net` | `127.0.0.1:3000` | OIDC (planned) |
| AirTrail | `flights.pierr.re` | `127.0.0.1:3001` | app / OIDC |
| Glance | `dash.pierr.re` | `127.0.0.1:5678` | SSO (forward-auth) |
| Immich | `photos.pierr.re` | `127.0.0.1:2283` | OIDC (planned) |
| Jellyfin | `jelly.pierr.re` / `jelly.piergabory.net` | `127.0.0.1:8096` | app / OIDC |
| Home Assistant | `hass.pierr.re` / `home.piergabory.net` | `127.0.0.1:8123` | app |
| Radicale | `dav.piergabory.net` | `127.0.0.1:5232` | Basic (bcrypt), no SSO |
| Vaultwarden | `vault.piergabory.net` | `127.0.0.1:8222` | own master password, no SSO |
| Dawarich | `geo.piergabory.net` | `127.0.0.1:64645` | app |
| Syncthing GUI | `sync.pierr.re` | `127.0.0.1:8384` | SSO (forward-auth) |

## Security posture and hardening

- SSH (`common/services/openssh.nix`): key-only (`PasswordAuthentication = false`, `KbdInteractiveAuthentication = false`), `PermitRootLogin = "no"`, `AllowUsers = [ "piergabory" ]`, `MaxAuthTries = 3`, and `PerSourcePenalties` for built-in brute-force mitigation. Authorized keys are listed in that module. This applies to both hosts, including the roaming ThinkPad. There is no `fail2ban`.
- Firewall: web services proxied by nginx bind to `127.0.0.1` and do not open their ports. When adding or changing a proxied service, ensure `openFirewall` is off and the app binds loopback, so traffic can only arrive through nginx (and Authelia where applicable).
- Pi-hole (`hosts/workstation/services/pihole.nix`): DNS (53) and admin web (8080) are exposed on the LAN interface only via `networking.firewall.interfaces.eth0`, never globally. `openFirewallDNS`/`openFirewallWebserver` are off. `eth0` is the MAC-pinned LAN NIC (see `modules/networking.nix`). Loopback resolution is unaffected.
- Radicale uses `htpasswd_encryption = "bcrypt"`; the `radicale` secret must contain bcrypt htpasswd entries (`htpasswd -B`).

## AirTrail

- Defined in `hosts/workstation/services/flights.nix`.
- Runs as two Podman containers: `airtrail` and `airtrail-db`.
- AirTrail runs in a Podman pod that publishes `127.0.0.1:3001:3000`; keep host port `3000` for Actual Budget.
- Persistent data lives under `/var/lib/airtrail/postgres` and `/var/lib/airtrail/uploads`.
- Env file comes from agenix secret `airtrail-env`, backed by `secrets/airtrail-env.age`.
- The AirTrail env should use `ORIGIN=https://flights.pierr.re`; `DB_URL` is generated at runtime to use `127.0.0.1` inside the pod.
- When configuring OAuth/OIDC for AirTrail, register the redirect/callback URI as `https://flights.pierr.re/api/oauth/callback`.
- AirTrail's OAuth `tokenEndpointAuthMethod` must be `client_secret_basic`, matching the Authelia `airtrail` client registration.

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
- The configuration must represent how the system is expected to be used in its steady state. Do not introduce temporary fixes, throwaway feature flags, or stopgap toggles; make the intended state the actual state.
- Prefer dedicated tools over driving one-off shell/`nix` commands to mutate or inspect runtime state. Use `nix eval` / `nixos-rebuild build` for validation, not to work around configuration.
- Prefer adding or changing focused modules near the relevant service or host.
- Avoid mixing unrelated service changes in one edit.
- Preserve host separation: shared behavior belongs in `common/`; host-only behavior belongs under `hosts/<host>/`.
- When adding secrets, update the agenix secret mapping and consume secret paths rather than embedding values.
- When changing service exposure, check nginx, firewall, and local bind addresses together. Services fronted by nginx should bind loopback and keep `openFirewall` off.
- When placing a service behind Authelia, serve it under a `pierr.re` host so the SSO session cookie applies, add `internalAuthLocation` at server level and `forwardAuthConfig` in the protected location, and add the host to Authelia's `access_control` rules. Only use forward-auth for browser-only apps; use native OIDC for apps with mobile/native clients.
- Keep Vaultwarden out of Authelia SSO.
- When adding backups for a stateful service, follow the existing restic pattern and reuse `config.piergabory.backups`.
- Run `nix flake check` (or at least `nixos-rebuild build`) after meaningful configuration changes when feasible.

## Known open items

These were identified but intentionally deferred; keep them in mind and revisit when appropriate:

- Home Assistant runs as a privileged, host-networked Podman container (`hosts/workstation/services/home-assistant.nix`). Hardening (dropping `privileged`, targeted capabilities, or migrating to the native module) was deferred to avoid smart-home disruption; validate on the hardware when attempted.
- Jellyfin runs as `piergabory:users` rather than a dedicated user, because its `dataDir` sits alongside media under `/storage` written by `piergabory`-owned rsync jobs. Moving to a dedicated user requires separating the Jellyfin state directory from the media tree first.
- Backups (restic + rsync) are on-host only (same `/storage` array). There is no offsite copy; this is the largest remaining disaster-recovery gap and also affects Vaultwarden and the restic password.
- The RuTracker credential previously committed in `hosts/workstation/services/media-server.nix` was removed from the working tree but remains in git history; it should be rotated and, if desired, scrubbed from history.
