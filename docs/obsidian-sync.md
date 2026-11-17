# Obsidian live sync

CouchDB in the `obsidian-sync` namespace (`kubernetes/apps/obsidian-sync/`) is the server for the
[Self-hosted LiveSync](https://github.com/vrtmrz/obsidian-livesync) Obsidian plugin.

- URL: `https://obsidian-sync.isaacschwarz.dev` (Cloudflare Tunnel -> Traefik -> CouchDB)
- Credentials: `sops -d kubernetes/apps/obsidian-sync/couchdb-admin.sops.yaml`
- Data: local-path PVC `couchdb-data`, pinned off the Pi (node affinity `storage NotIn sdcard`)
- Backup: there is no replication. The vault's git repo (obsidian-git on the desktop) is the recovery path.

## Cloudflare
The tunnel is token-managed, so its routes live in the Cloudflare dashboard, not in git.
Add a public hostname `obsidian-sync.isaacschwarz.dev` pointing at the same Traefik URL as `isaacschwarz.dev`.
If Bot Fight Mode blocks sync requests, add a skip rule for this hostname.

## First device
1. Install the "Self-hosted LiveSync" community plugin.
2. Run its setup wizard: the URL and credentials above, database name `vault67`.
3. Turn on end-to-end encryption with a passphrase (the server then only stores ciphertext).
4. Choose the **LiveSync** preset.

## More devices
On the first device run the command "Copy setup URI", then paste it into the plugin on the new device.
