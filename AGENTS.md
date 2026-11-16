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
