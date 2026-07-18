# Multi-Protocol Bridge

This example exposes a "queue" of heterogeneous backend servers — FTP, WebDAV, SFTP, and more — through a
single S3-compatible endpoint using rclone's [`combine`](https://rclone.org/combine/) backend.

Each backend appears as its own S3 bucket, so a client using a standard S3 SDK or CLI can reach every server
through one connection and one set of credentials.

## Prerequisites

-   Docker and Docker Compose installed.
-   Connection details (host, username, password) for each backend server you want to bridge.
-   `rclone` installed locally (recommended) to generate an encrypted `rclone.conf` via `rclone config`.

## Quick Start

1.  **Create a `.env` file:**
    Copy `.env.example` to `.env` and set the S3 credentials that clients will use to connect to the bridge.
    These become `RCLONE_AUTH_KEY`, which authenticates incoming requests to the `serve s3` endpoint — without
    it the endpoint is anonymous.
    ```sh
    cp .env.example .env
    ```

2.  **Create `rclone.conf`:**
    Copy `rclone.conf.example` to `rclone.conf` and fill in one upstream remote per backend server. Then map
    each remote to a bucket name in the `[combined]` section's `upstreams` line.
    ```sh
    cp rclone.conf.example rclone.conf
    ```
    For obscured passwords, prefer generating the file with `rclone config` (or run `rclone obscure <password>`).

3.  **Start the service:**
    ```sh
    docker compose up -d
    ```

4.  **Access the S3 endpoint:**
    The S3-compatible endpoint is available at `http://localhost:8080`. Each backend server is a bucket.
    ```sh
    aws --endpoint-url http://localhost:8080 s3 ls
    aws --endpoint-url http://localhost:8080 s3 ls s3://webdav-server/
    ```
    -   **Access Key ID:** `S3_ACCESS_KEY_ID` from your `.env` file.
    -   **Secret Access Key:** `S3_SECRET_ACCESS_KEY` from your `.env` file.

## File Structure

-   `docker-compose.yml`: The Docker Compose file for the bridge service.
-   `.env.example`: An example environment file with the S3 gateway credentials.
-   `rclone.conf.example`: An example rclone configuration with WebDAV, FTP, and SFTP upstreams plus the
    `combine` remote.
-   `README.md`: This file.

## How It Works

The bridge runs a single `rclone serve s3 combined:` process. The `combined` remote is a `combine` backend
whose `upstreams` line stitches several independent remotes into one namespace:

```ini
[combined]
type = combine
upstreams = webdav-server=webdav-remote: ftp-server=ftp-remote: sftp-server=sftp-remote:
```

Each `bucket-name=remote:` pair becomes a top-level directory, which `rclone serve s3` presents as an S3
bucket. A request for `s3://ftp-server/path/file.txt` is transparently routed to the `ftp-remote` backend, so
clients never need to know which protocol sits behind each bucket.

### Adding or removing backend servers

1.  Define (or delete) the upstream remote section in `rclone.conf` — for example a new `[s3-remote]` block.
2.  Add (or remove) the matching `<bucket-name>=<remote>:` entry in the `[combined]` `upstreams` line.
3.  Restart the service: `docker compose up -d`.

The new backend immediately shows up as an additional bucket at the same S3 endpoint; existing clients keep
their connection and credentials unchanged.

## Security Note

`rclone serve s3` is an **experimental** feature — review the [rclone S3 serve docs](https://rclone.org/commands/rclone_serve_s3/)
before relying on it in production.

Incoming requests are authenticated via `RCLONE_AUTH_KEY` (set from `.env`). The endpoint serves plain HTTP and
is bound to `127.0.0.1` by default; for any non-local exposure, front it with TLS (rclone `--cert`/`--key` or a
reverse proxy) before changing the port binding.

Do **not** store plain-text passwords in `rclone.conf`. Generate the file with `rclone config`, which obscures
the `pass` values, or obscure individual values with `rclone obscure <password>`. Obscuring is reversible and
does not encrypt the file — set a config password via `rclone config` if you need encryption at rest. Keep
`.env`, `rclone.conf`, and any private keys (e.g. `id_rsa`) out of version control.
