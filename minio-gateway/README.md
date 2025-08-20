# MinIO Gateway Solution (Modern Approach)

This directory contains a solution for using a WebDAV server as a storage backend for a MinIO S3-compatible object storage server.

## Overview

MinIO's traditional "gateway" mode has been deprecated. This solution provides a modern alternative by using `rclone mount` to mount your WebDAV share into a Docker volume. A standard MinIO server then uses this mounted directory as its backend storage.

This effectively creates a live "gateway" from an S3 API (provided by MinIO) to your WebDAV server.

**Security Warning:** This solution requires the `rclone` container to run with elevated privileges (`--cap-add SYS_ADMIN` and access to `/dev/fuse`). This is necessary for `rclone mount` to function. Be aware of the security implications before deploying this in a production environment.

## Quick Start

1.  **Prepare the host:** The `rclone mount` command requires FUSE to be installed on the Docker host machine.
    ```sh
    # On Debian/Ubuntu
    sudo apt-get update && sudo apt-get install -y fuse3

    # On CentOS/RHEL
    sudo yum install -y fuse3
    ```

2.  **Create a `.env` file:**
    Copy `.env.example` to `.env` and fill in the required values for your WebDAV server and your desired MinIO credentials.
    ```sh
    cp .env.example .env
    ```

3.  **Create `rclone.conf`:**
    Create a `rclone.conf` file with the configuration for your WebDAV remote. See the `rclone.conf.example` for a template. It is highly recommended to use `rclone config` to create this file, as it will encrypt your password.

4.  **Start the services:**
    ```sh
    docker-compose up -d
    ```

5.  **Access the S3 endpoint:**
    -   **MinIO Console:** `http://localhost:9001`
    -   **S3 Endpoint:** `http://localhost:9000`
    -   **Root User (Access Key):** `MINIO_ROOT_USER` from your `.env` file.
    -   **Root Password (Secret Key):** `MINIO_ROOT_PASSWORD` from your `.env` file.

## How It Works

This solution consists of two services orchestrated by Docker Compose:

1.  **`rclone-mount` service:**
    -   Uses the `rclone/rclone` image.
    -   Mounts the WebDAV remote (e.g., `webdav-remote:`) to a directory inside the container (`/mnt/webdav`).
    -   This mount point is stored in a shared Docker volume (`webdav_data`).
    -   Requires elevated privileges to interact with the host's FUSE system.

2.  **`minio` service:**
    -   Uses the official `minio/minio` image.
    -   Mounts the shared Docker volume (`webdav_data`) to its data directory (`/data`).
    -   Starts a standard MinIO server using this directory as its backend.

Any file uploaded to MinIO will be written to the `rclone` mount, which in turn writes it to the WebDAV server.

## Files

-   `docker-compose.yml`: The Docker Compose file for the services.
-   `.env.example`: An example environment file with required variables.
-   `rclone.conf.example`: An example rclone configuration file.

## Performance Considerations

-   The performance of this setup is highly dependent on the performance of your WebDAV server and the network latency between the Docker host and the WebDAV server.
-   `rclone mount` has many tuning parameters. You may need to adjust the `command` in the `docker-compose.yml` file with flags like `--vfs-cache-mode`, `--vfs-read-chunk-size`, etc., to optimize for your use case. Refer to the [rclone mount documentation](https://rclone.org/commands/rclone_mount/) for more details.
