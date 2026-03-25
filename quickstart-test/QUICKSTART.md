# Quick Start Guide

This guide will help you get your rclone S3 proxy service running.

## 1. Review Configuration

-   **`docker-compose.yml`**: This file defines the rclone service.
-   **`.env`**: This file contains your S3 gateway credentials. **Keep this file secure.**
-   **`rclone.conf`**: This file contains your WebDAV backend credentials. **Keep this file secure.**

## 2. Start the Service

Navigate to this directory in your terminal and run the following command:

```sh
docker-compose up -d
```

## 3. Access Your S3 Gateway

Your S3-compatible endpoint is now available at: `http://localhost:8080`

You can connect to it using an S3 client with the credentials you provided, which are stored in the `.env` file.

## 4. Stopping the Service

To stop the service, run:

```sh
docker-compose down
```
