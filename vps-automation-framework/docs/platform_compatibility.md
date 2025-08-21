# Platform Compatibility Guide (Coolify & Dokploy)

This guide provides tips and explains common pitfalls when deploying the generated Docker Compose files to managed platforms like Coolify and Dokploy. These platforms provide a fantastic, streamlined experience but have their own way of handling networking and configuration that can conflict with a standard `docker-compose.yml`.

## Key Concepts

Both Coolify and Dokploy use a reverse proxy (typically Traefik) to automatically manage network traffic, assign domains, and provide SSL certificates. This means you should **not** manually expose ports in your `docker-compose.yml` file.

## Coolify

Coolify is a self-hostable platform that simplifies application deployment.

### Networking
-   **Ports**: Do **not** use the `ports` mapping (e.g., `ports: - "8000:8000"`) in your `docker-compose.yml`. Coolify's reverse proxy will handle exposing your application.
-   **Domains**: In the Coolify UI, you will specify the domain or subdomain for your service (e.g., `litellm.your-domain.com`). Coolify will configure the reverse proxy to route traffic to your container on its internal network.
-   **Network Mode**: Coolify creates a dedicated Docker network for each project. Your services will automatically be on this network and can communicate with each other using their service names as hostnames (e.g., `http://litellm-proxy:8000`).

### Environment Variables
-   **Source of Truth**: Use the "Environment Variables" tab in the Coolify UI to manage your secrets and configurations.
-   **Conflicts**: The interactive generator creates a `.env` file. When deploying to Coolify, you should copy the contents of this file into the UI. Do not rely on the `.env` file itself being loaded automatically, as Coolify's injection mechanism is the recommended approach.

## Dokploy

Dokploy is another self-hostable platform with similar principles.

### Networking
-   **Ports**: Like Coolify, you should remove the `ports` section from your `docker-compose.yml`.
-   **Domains & Reverse Proxy**: In the Dokploy UI, you will configure the domain for your service under the "Domains" section. Dokploy will manage the reverse proxy and SSL certificates.
-   **Internal Network**: Services within the same project can communicate over a shared Docker network.

### Environment Variables
-   Use the "Environment Variables" section in the Dokploy UI to manage your configuration. Copy the key-value pairs from the generated `.env` file here.

## General Recommendations for Both Platforms

-   **Health Checks**: Both platforms support Docker health checks. The generated `docker-compose.yml` files from the "Production" workflow (when implemented) will include these.
-   **Volumes**: Both platforms handle Docker volumes correctly. The generated configurations that mount local paths (e.g., `./config`) will map to a persistent storage location managed by the platform.
-   **`restart: unless-stopped`**: This policy is generally respected and is a good default.

By letting the platform handle networking and environment variables, you get the full benefit of their management features, including automatic SSL, domain routing, and a secure way to manage secrets. Our interactive generator will attempt to create a compatible `docker-compose.yml` if you select Coolify or Dokploy as your target platform.
