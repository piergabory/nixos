# Repository context

Keep this file current when work in this repository changes the machine roles,
deployment boundaries, or configuration ownership documented below. Record only
confirmed, durable facts; do not add generic advice or session progress notes.

## Machine roles

This repository manages my machines and deploys my personal services.

- **macbook**: company-owned Mac. The only machine used for Swift development
  and Netatmo / Legrand work. Darwin Swift tooling uses the selected Xcode
  toolchain; editor SourceKit and formatting commands run through `xcrun`.
- **workstation**: my main personal desktop and home server. Hosts my services
  and may be used for small personal coding projects. This NixOS configuration
  is the main project through which I manage and deploy those services.
- **offsite**: an old Mac mini running NixOS, dedicated solely to off-site backups
  of workstation's services in case my apartment is lost, for example to fire.
  It is not another application server or development machine.
- **thinkpad** and **droid**: personal computers, unrelated to company work.

## Work / personal boundary

Netatmo / Legrand project instructions and work MCP registrations belong exclusively
to the **macbook** configuration, scoped to `~/Developer`. Do not deploy
them through shared profiles or to any personal machine.

Their static sources live in `configurations/darwin/ai/` and are deployed by
`configurations/darwin/darwin.nix`. Canonical company guidance remains in the
separate company checkout; it is referenced, not copied into this repository.

Company skills remain globally installed by company tooling, not managed by Nix.
On macbook, `configurations/darwin/ai/global/AGENTS.md` is deployed as OpenCode's
global instruction file with a brief note about their intended scope.

The root `AGENTS.md` describes this repository; it is not a global instruction file
to distribute to the machines.

## Webmail

`modules/homelab/bulwark/` owns workstation's Bulwark webmail at `mail.pierr.re`
and its HTTP-only Stalwart backend at `jmap.pierr.re`. Bulwark signs users
in through Authelia with OIDC authorization code + PKCE, and Stalwart validates
their access tokens through Authelia's UserInfo endpoint. The `bulwark` OIDC
client registration belongs in the authentication module's encrypted client
registry. `modules/homelab/bulwark/legacy-proxy.nix` owns an OCI-container
iCloud IMAP/SMTP-to-JMAP bridge at `icloud-jmap.pierr.re`. Bulwark offers it
as a separate, app-password-authenticated mail account alongside Stalwart;
contacts and calendars stay on Stalwart. The bridge reuses persistent state
in `/var/lib/bulwark-legacy-proxy` and locally generated vault/session keys in
`/var/lib/bulwark-legacy-proxy-secrets/proxy.env`, outside the Nix store.

`modules/homelab/bulwark/stalwart.nix` enables Stalwart alongside Bulwark. Its data lives
in `/var/lib/stalwart`, and its fallback-admin secret is managed by agenix under
`modules/homelab/bulwark/secrets/`. Stalwart owns the contacts, calendars, and tasks
migrated from Radicale for `piergabory`. Native clients use CalDAV/CardDAV on
`jmap.pierr.re`; the inherited DAV password is stored as a Stalwart app password,
while Bulwark retains Authelia SSO. Radicale at `dav.pierr.re` remains a read-only
rollback source, with its original data and backups retained.

Stalwart's nightly Restic backup takes a cold filesystem snapshot, briefly stopping
the service before archiving `/var/lib/stalwart`. Calendar scheduling and server-side
email alarms are disabled until mail delivery is configured. Email hosting and DNS
remain unchanged. Operational and restore details are in
`modules/homelab/bulwark/README.md`.

## Personal agent tooling

On **droid**, `configurations/linux/droid/opencode-package.nix` repackages the
pinned upstream ARM64 CLI release instead of building OpenCode's Bun workspaces
on the phone. `configurations/linux/droid/opencode.nix` selects this package,
owns the phone's `~/.local/bin/opencode` link, and adapts the pinned Stylix
target to OpenCode 2's `cli.json`. Other machines retain the Nixpkgs package and
desktop app. Droid's PRoot and activation workarounds also live under
`configurations/linux/droid/`.

`home/developer/hunk/default.nix`, imported by the shared OpenCode module, owns the global
Hunk review skill, code-review communication guidance, and `hunk-review-open`
launcher. The launcher reuses or opens a Hunk pane in the matching OpenCode
Zellij tab without taking keyboard focus. This tooling is not company-specific.

## Temporary workarounds

`modules/homelab/pihole/pihole-ftl.nix` temporarily overrides the entire
`environment.etc."pihole/versions"` entry with `mkForce` because nixpkgs reads
the nonexistent `piholePackage.src.src.tag` instead of `piholePackage.src.tag`.
Overriding only `.text` still evaluates the broken upstream expression.
At the next nixpkgs update or Pi-hole maintenance opportunity, check whether
upstream has fixed this, remove the override as soon as a rebuild succeeds
without it, and remove this note too.
