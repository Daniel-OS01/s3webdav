# SeaweedFS Solution

This directory contains a solution for using SeaweedFS to provide an S3-compatible gateway to a backend that uses a WebDAV server for metadata storage.

## Overview

This solution leverages SeaweedFS's powerful distributed object store capabilities and its S3-compatible gateway. To bridge with an existing WebDAV server, this setup uses `rclone mount` to make the WebDAV share available as a local directory. The SeaweedFS **filer**, which manages the file and directory structure, is then configured to use this mounted directory as its storage backend for metadata.

The actual file content (the "chunks") is stored in a SeaweedFS **volume server**, providing high performance for data operations. The **S3 gateway** then exposes the filer's namespace as an S3 bucket.

**Security Warning:** This solution requires the `rclone` container to run with elevated privileges (`--cap-add SYS_ADMIN` and access to `/dev/fuse`). This is necessary for `rclone mount` to function. Be aware of the security implications before deploying this in a production environment.

## Architecture

This setup consists of five main services:
1.  **`rclone-mount`**: Mounts the external WebDAV share to a shared volume.
2.  **`seaweedfs-master`**: The coordinator of the SeaweedFS cluster. It manages volumes and filers.
3.  **`seaweedfs-volume`**: The data workhorse. It stores the actual file content in large "volume" files.
4.  **`seaweedfs-filer`**: Manages the filesystem metadata (filenames, directories, permissions). It is configured to store its metadata database on the `rclone` mount.
5.  **`seaweedfs-s3`**: The S3 gateway, which translates S3 API calls into filer operations.

## Prerequisites

-   A server with Docker and Docker Compose installed.
-   FUSE installed on the Docker host (`sudo apt-get install -y fuse3` or `sudo yum install -y fuse3`).
-   A WebDAV server that `rclone` can connect to.

## Quick Start

1.  **Configure `rclone`**:
    -   Create a valid `rclone.conf` file for your WebDAV backend. You can copy `rclone.conf.example` and modify it.

2.  **Configure SeaweedFS**:
    -   Create a `.env` file from `.env.example` and review the settings.
    -   Review `config/filer.toml` to see the filer configuration.

3.  **Launch the stack**:
    ```sh
    docker-compose up -d
    ```

4.  **Access the S3 endpoint**:
    -   The S3 endpoint will be available at `http://localhost:8333`.
    -   You can use an S3 client like `s3cmd` or `mc` to interact with it. The access key and secret key can be anything as they are not checked by default in this configuration.

## File Structure

-   `docker-compose.yml`: Defines the five services required for the solution.
-   `.env.example`: Template for environment variables.
-   `rclone.conf.example`: Example `rclone` configuration for your WebDAV remote.
-   `config/`: Directory for SeaweedFS configuration files.
-   `config/filer.toml`: The configuration file for the SeaweedFS filer service.

## How It Works

1.  The `rclone-mount` service mounts your WebDAV share to a Docker volume (`webdav_metadata`).
2.  The `seaweedfs-master` and `seaweedfs-volume` services start up, forming a basic storage cluster. The volume server stores data in a separate Docker volume (`seaweedfs_data`).
3.  The `seaweedfs-filer` service starts and, using its `filer.toml` configuration, connects to the master and uses the `/data` directory (which is the `webdav_metadata` volume) for its metadata store.
4.  The `seaweedfs-s3` gateway starts, connects to the filer, and exposes its filesystem namespace via the S3 protocol on port 8333.
5.  When you upload a file via the S3 gateway, the metadata (filename, path) is written by the filer to the WebDAV share, and the file content is written to the volume server.
