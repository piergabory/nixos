# Rename Local User Plan

## Goal

Rename the local Unix user from `piergabory` to a shorter name such as `pier` or `pierre` while keeping the existing domain, email addresses, and public service names unchanged.

This plan is only about the local computer account name and home directory.

## Important Distinction

Do not globally replace every occurrence of `piergabory`.

Many references are domain names, email addresses, service URLs, or public identities and should remain unchanged, for example:

- `piergabory.net`
- `mail@piergabory.net`
- `piergabory@icloud.com`
- public nginx virtual hosts
- service URLs shown in Glance

Only local Unix account references should change.

## Main Risk

Files are owned by numeric UID/GID, not by username strings.

If the NixOS config is changed from `users.users.piergabory` to `users.users.pier` and then switched directly, NixOS may create a new user instead of renaming the old one. The old files may remain owned by the old UID, while the new user may get a different UID.

That can break:

- Home Manager activation.
- Syncthing folder access.
- Samba share access.
- rsync jobs.
- Jellyfin access to its configured paths.
- age secret file ownership.
- Any service or script using `/home/piergabory`.

The safe approach is to rename the real Unix account while preserving the existing UID, then update Nix to match.

## Preconditions

- Decide the new username, for example `pier` or `pierre`.
- Make sure no graphical session for `piergabory` is active.
- Make sure important data is backed up.
- Do not change domain or email references unless explicitly intended.
- Do not expose or edit secret values during this process.

## High-Level Safe Procedure

1. Stop user-facing services that may touch the home directory or user-owned data.
2. Rename the actual Unix account while preserving UID.
3. Move the home directory from `/home/piergabory` to the new path.
4. Rename the matching primary group only if one exists and is actually used.
5. Update the Nix configuration to use the new local username.
6. Rebuild with `nixos-rebuild switch`.
7. Verify ownership, services, Home Manager activation, Syncthing, Samba, and backups.

## Commands To Run Manually

Replace `pier` with the chosen username.

Stop services first as appropriate for the current machine:

```sh
sudo systemctl stop syncthing.service
sudo systemctl stop jellyfin.service
sudo systemctl stop rsync-documents.timer rsync-notes.timer rsync-music.timer || true
```

Rename the user and move the home directory:

```sh
sudo usermod -l pier -d /home/pier -m piergabory
```

If there is a matching private group named `piergabory`, rename it too:

```sh
getent group piergabory
sudo groupmod -n pier piergabory
```

Check that the UID was preserved:

```sh
id pier
ls -ld /home/pier
```

The UID should be the same as the old account, likely `1000`.

## Nix Configuration References To Update

Update local username references in these areas:

- `common/modules/users.nix`
- `common/default.nix`
- `common/home/default.nix`
- `common/home/accounts/*.nix` username guards only
- `common/home/programs/minecraft.nix` username guard
- `common/home/xdg.nix` username guards
- `hosts/workstation/services/syncthing.nix`
- `hosts/thinkpad/services/syncthing.nix`
- `hosts/workstation/services/samba.nix`
- `hosts/workstation/services/rsync.nix`
- `hosts/workstation/services/jellyfin.nix`
- `secrets/default.nix` age secret owners for user-readable secrets

Also update hardcoded home paths that refer to local files:

- `/home/piergabory/Notes`
- `/home/piergabory/Desktop`
- `/home/piergabory/Documents`
- `/home/piergabory/Music`
- any other local `/home/piergabory/...` paths

Do not update domain/email/public identity references unless intentionally changing public identity.

## Secret Handling

age secret values must remain user-managed.

The configuration may need age secret owner names changed from `piergabory` to the new local username. This changes file ownership at activation time, not the secret values.

If any age secret file must be created, rekeyed, or edited, Pierre should do that manually and then signal when it is ready. Agents should not see, decrypt, print, or handle secret values.

## Verification

After editing the Nix configuration, run:

```sh
nix flake check
sudo nixos-rebuild switch --flake /etc/nixos#workstation
```

On the ThinkPad, use the ThinkPad target instead:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#thinkpad
```

Then verify:

- `id <new-user>` shows the expected UID.
- `/home/<new-user>` exists and is owned by the new username.
- `/home/piergabory` no longer exists, or only exists intentionally as a temporary compatibility path.
- Home Manager activation succeeds.
- Syncthing starts and sees the expected folders.
- Samba authentication still works.
- rsync jobs still use the expected source paths.
- Jellyfin can access its configured data paths.
- user-owned age secrets under `/run/agenix` have the new owner.
- `nix.settings.trusted-users` includes the new username.

## Rollback Notes

If the rename causes issues, the most important fact is the UID. If the UID was preserved, file ownership should still map cleanly to whichever username currently owns that UID.

Avoid deleting the old user or home directory until the new login, Home Manager activation, and services are confirmed working.
