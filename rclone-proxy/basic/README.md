# rclone-proxy: Basic Setup

This directory contains a basic setup for exposing a WebDAV server as an S3-compatible endpoint using `rclone`.

This setup is ideal for development, testing, or personal use. It is not recommended for production without further security hardening.

## Quick Start

1.  **Create a `.env` file:**
    Copy the `.env.example` to `.env` and fill in the required values for your WebDAV server.
    ```sh
    cp .env.example .env
    ```

2.  **Create `rclone.conf`:**
    Create a `rclone.conf` file with the configuration for your WebDAV remote. A minimal example is provided in `rclone.conf.example`. You can also copy a pre-existing `rclone.conf` file from your local machine (usually found at `~/.config/rclone/rclone.conf`).

3.  **Start the service:**
    ```sh
    docker-compose up -d
    ```

4.  **Access the S3 endpoint:**
    The S3-compatible endpoint will be available at `http://localhost:8080`.

    -   **Access Key ID:** `S3_ACCESS_KEY_ID` from your `.env` file.
    -   **Secret Access Key:** `S3_SECRET_ACCESS_KEY` from your `.env` file.

## Files

-   `docker-compose.yml`: The Docker Compose file for the service.
-   `.env.example`: An example environment file with required variables.
-   `rclone.conf.example`: An example rclone configuration file.

## Configuration Options

### `docker-compose.yml`

-   The `rclone/rclone` image is used.
-   The service is named `rclone-proxy`.
-   It exposes port `8080`.
-   It mounts the local `rclone.conf` file into the container.
-   The command `rclone serve s3 webdav-remote: --addr :8080` starts the S3 server, serving the `webdav-remote` defined in your `rclone.conf`.

### `.env`

| Variable | Description |
| --- | --- |
| `S3_ACCESS_KEY_ID` | The access key for the S3 endpoint. |
| `S3_SECRET_ACCESS_KEY` | The secret key for the S3 endpoint. |

### `rclone.conf`

You need to have a remote configured for your WebDAV server. Here is an example for a generic WebDAV server:

```ini
[webdav-remote]
type = webdav
url = https://your-webdav-server.com/remote.php/dav/files/username/
vendor = other
user = your-webdav-username
pass = your-encrypted-password
```

**Important:** Use `rclone config` to create your `rclone.conf` file. It will encrypt your password for you. Do not store plain-text passwords in this file.
