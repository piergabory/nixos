# Bulwark

Bulwark at `https://mail.pierr.re` connects to two separate JMAP accounts:

- **Calendars and contacts**: Stalwart at `https://jmap.pierr.re`, signed in
  through Authelia. Existing CalDAV/CardDAV clients keep using this server.
- **iCloud Mail**: the legacy bridge at `https://icloud-jmap.pierr.re/jmap/session`.
  Select this server when adding an account, then use your primary full iCloud
  email address and an Apple app-specific password, not your Apple Account password.

Use Bulwark's account menu to add the second account and switch between them.
The accounts do not share contacts or calendars automatically. iCloud-hosted
custom-domain sender addresses may need to be added as identities in the mail
account; Apple must already authorise those addresses.

## iCloud bridge

`legacy-proxy.nix` runs the pinned upstream OCI image through Podman. Its HTTP
port is bound to `127.0.0.1:3004`, behind nginx with HTTPS. Only Apple's IMAP
and SMTP servers are configured; CardDAV, Sieve and provider discovery are not
enabled. No incoming SMTP port, MX records or email hosting changes are needed.
The bridge's built-in login limits trust the default Podman gateway
`10.88.0.1` for nginx's forwarded client addresses; update that setting if the
container network changes.

On activation, the secrets service creates vault/session keys only if absent.
Existing keys and databases are reused. The keys live in
`/var/lib/bulwark-legacy-proxy-secrets/proxy.env` (root-only), not the Nix store.
The bridge database, cached messages and uploads live in
`/var/lib/bulwark-legacy-proxy`, owned by UID 100 / GID 101 from the pinned image.

These bridge directories are not added to Restic: iCloud remains authoritative
for mail, and the bridge can be recreated by signing in again. To preserve
bridge state in a manual recovery, retain both its stopped database directory
and the matching keys, protecting the keys separately from the database backup.
Never generate replacement vault keys for an existing database; startup refuses
to do so. Do not remove the bridge state while mail uploads or sends are pending.

After rebuilding, check:

```console
systemctl status bulwark-legacy-proxy-secrets podman-bulwark-legacy-proxy
curl --fail http://127.0.0.1:3004/healthz
curl -I https://icloud-jmap.pierr.re/jmap/session
```

An unauthenticated session request should return `401`. Mail remains available
through iCloud.com and directly connected mail apps if the home server is down.

## Stalwart backup and restore

Stalwart stores its data in `/var/lib/stalwart`. Its nightly Restic job stops
the service briefly and archives the data into
`/var/backup/restic/stalwart/data.tar` before restarting it. Restic backs up that
archive, with offsite replication following the existing workstation schedule.

To restore, stop Stalwart, recover the desired `data.tar` from Restic, preserve
the current data directory, and extract the archive into `/var/lib/stalwart`.
Restore ownership to the configured Stalwart service user/group before starting
the service. Verify calendars and contacts through JMAP and a DAV client.
Keep Radicale's read-only data and backups as the separate migration rollback
source. Server-side scheduling and email alarms remain disabled until a mail
delivery path is deliberately configured.
