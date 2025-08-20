# Traefik Secured Solution

This directory contains a fully-featured example of how to use Traefik as a reverse proxy to secure a backend WebDAV-to-S3 bridge. It provides automatic HTTPS via Let's Encrypt, security middleware, and a clear structure for configuration.

This example uses the `rclone-proxy` solution from this repository as the backend service, but it can be adapted to secure any of the other solutions.

## Features

-   **Automatic HTTPS**: Traefik handles SSL certificate provisioning and renewal from Let's Encrypt automatically.
-   **Security Headers**: Includes middleware to add important security headers (e.g., HSTS, CSP) to responses.
-   **Docker Integration**: Uses Traefik's Docker provider to automatically discover and configure services based on labels in the `docker-compose.yml`.
-   **Centralized Configuration**: Separates static (`traefik.yml`) and dynamic (`config/dynamic.yml`) configurations for clarity and flexibility.
-   **Basic Authentication**: Demonstrates how to add HTTP Basic Authentication to a service.

## Prerequisites

-   A server with Docker and Docker Compose installed.
-   A registered domain name (e.g., `your-domain.com`).
-   A DNS `A` record pointing from your desired subdomain (e.g., `s3.your-domain.com`) to your server's IP address.

## Quick Start

1.  **Clone this repository** (if you haven't already).

2.  **Configure `rclone`**:
    -   Navigate to the `rclone-proxy/basic` directory.
    -   Create a valid `rclone.conf` file for your WebDAV backend. You can copy `rclone.conf.example` and modify it, but it's best to generate it with `rclone config`.

3.  **Configure Traefik**:
    -   Navigate to this directory (`/traefik-secured/`).
    -   Create a `.env` file from the example: `cp .env.example .env`.
    -   Edit `.env` and set your `DOMAIN_NAME` and `LETSENCRYPT_EMAIL`.
    -   Review `config/dynamic.yml` to adjust middleware if needed. For example, you can set a password for Basic Auth.

4.  **Launch the stack**:
    ```sh
    docker-compose up -d
    ```

5.  **Access your secured S3 endpoint**:
    -   Your S3-compatible endpoint will be available at `https://s3.your-domain.com`.
    -   The Traefik dashboard (if enabled) will be at `https://traefik.your-domain.com`.
    -   Traffic is automatically redirected from HTTP to HTTPS.

## File Structure

-   `docker-compose.yml`: Defines the Traefik and `rclone-proxy` services. Service discovery is handled via Docker labels.
-   `.env.example`: Template for environment variables.
-   `traefik.yml`: Traefik's static configuration. This defines entry points (HTTP, HTTPS), the Docker provider, and the Let's Encrypt certificate resolver.
-   `config/`: A directory for dynamic configuration files.
-   `config/dynamic.yml`: Traefik's dynamic configuration. This defines middleware (e.g., security headers, basic auth) and can be used for more complex routing rules that are not defined via Docker labels.

## How It Works

-   The `docker-compose.yml` file launches two services: `traefik` and `rclone-proxy`.
-   The `traefik` service is configured via the `traefik.yml` file, which tells it to listen on ports 80 and 443, and to use the Docker provider for service discovery.
-   The `rclone-proxy` service has a set of `labels` that Traefik reads. These labels tell Traefik:
    -   To expose this service.
    -   Which router to use (`s3-secure`).
    -   The domain name to use (`Host(`s3.${DOMAIN_NAME}`)`).
    -   Which TLS certificate resolver to use (`letsencrypt`).
    -   Which middleware to apply (e.g., `sec-headers`, `simple-auth`).
-   When a request comes to `https://s3.your-domain.com`, Traefik routes it to the `rclone-proxy` container on its internal Docker network. Before forwarding the request, it applies the specified middleware.
-   The `rclone.conf` and S3 credentials for the rclone service are managed via its own `.env` file located in the `rclone-proxy/basic` directory, keeping the concerns separate.
