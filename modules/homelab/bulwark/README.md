# Bulwark Lite

Bulwark Lite at `https://mail.pierr.re` connects only to **iCloud Mail** through
the legacy bridge at `https://icloud-jmap.pierr.re`. Sign in with your primary
full iCloud email address and an Apple app-specific password, not your Apple
Account password. There is no server selector or Authelia sign-in in this client.

`default.nix` pins the upstream static release archive and serves it directly
from the Nix store through nginx, with a generated `config.json`. There is no
Bulwark Node.js service or listener on port 3002. The browser talks directly to
the HTTPS bridge; its built-in CORS handling permits the webmail origin.
The site's Content-Security-Policy restricts connections to the webmail origin
and the iCloud bridge. Localised deep links use the matching static page shell.

Lite has no plugins, admin console, server-side settings sync or web push.
Settings stay in the browser; export/import them when moving devices. The
bridge uses Basic authentication rather than Stalwart refresh tokens, so sign-in
lasts for the browser tab instead of offering persistent "remember me" sessions.
Export any settings you want to retain before switching from the full edition,
and sign in again afterwards. If the old app remains cached, clear this site's
cached files and old service worker, then reload (export local settings first).

Stalwart at `https://jmap.pierr.re` remains the contacts, calendars and tasks
server for existing CalDAV/CardDAV clients, with its data, authentication and
backups unchanged. It is not offered in Lite. The old encrypted `bulwark` OIDC
client registration is retained for rollback but is unused by Lite.

Use the bridge's base URL without `/jmap/session`: Lite appends
`/.well-known/jmap` for discovery, and the bridge redirects it to the session.
iCloud-hosted custom-domain sender addresses may need to be added as identities
in the mail account; Apple must already authorise those addresses.

## Deploy and update

The homelab enables `services.bulwark-lite.enable`, which also keeps Stalwart and
the existing iCloud bridge enabled. Rebuild workstation to replace the full
webmail service with the static site; no bridge database or key migration is
needed. Existing `/var/lib/bulwark` state is left untouched for rollback.

To update Lite, change `version` and the unpacked archive hash in `default.nix`.
Keep the generated configuration and nginx routing/security headers aligned
with the upstream static hosting guide and the archive's `nginx.conf.example`.
Lite has no in-app update checker.

After rebuilding, check the deployed version, fixed endpoint and deep links:

```console
curl --fail https://mail.pierr.re/lite-build.json
curl --fail https://mail.pierr.re/config.json
curl -I https://mail.pierr.re/fr/mail/thread/test
curl -i -X OPTIONS https://icloud-jmap.pierr.re/jmap \
  -H 'Origin: https://mail.pierr.re' \
  -H 'Access-Control-Request-Method: POST' \
  -H 'Access-Control-Request-Headers: authorization,content-type'
```

The deep link should serve HTML with `200`; the preflight should return `204`
and allow `https://mail.pierr.re`, `authorization` and `content-type`. Then test
sign-in, opening mail, sending, and attachment uploads/downloads in the browser.

## iCloud bridge

`legacy-proxy.nix` runs the pinned upstream OCI image through Podman. Its HTTP
port is bound to `127.0.0.1:3004`, behind nginx with HTTPS. Only Apple's IMAP
and SMTP servers are configured; CardDAV, Sieve and provider discovery are not
enabled. No incoming SMTP port, MX records or email hosting changes are needed.
The bridge's built-in login limits trust the default Podman gateway
`10.88.0.1` for nginx's forwarded client addresses; update that setting if the
container network changes.

`icloud-compat.cjs` is preloaded before ImapFlow to quote colon-bearing
`KEYWORD`/`UNKEYWORD` search arguments. iCloud rejects the unquoted `$label:*`
keywords used by Bulwark's tag counters with `BAD Parse Error`. Recheck whether
this workaround is needed when upgrading the pinned bridge/ImapFlow version.

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
curl -I https://icloud-jmap.pierr.re/.well-known/jmap
curl -I https://icloud-jmap.pierr.re/jmap/session
```

Discovery should redirect to `/jmap/session`; an unauthenticated session request
should return `401`. A `404` for `/jmap/session/.well-known/jmap` during sign-in
means the client was given the session URL instead of the base URL.
Mail remains available
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
