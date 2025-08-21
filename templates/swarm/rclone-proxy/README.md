# rclone-proxy: Docker Swarm Deployment

This directory contains the necessary files to deploy the `rclone-proxy` solution to a Docker Swarm cluster.

This setup is designed for a production-like environment, using Docker's native `configs` and `secrets` to manage configuration and sensitive data securely.

## Prerequisites

-   A running Docker Swarm cluster.
-   `rclone.conf`: A valid rclone configuration file.
-   `S3_ACCESS_KEY_ID`: The access key for your S3 gateway.
-   `S3_SECRET_ACCESS_KEY`: The secret key for your S3 gateway.

## Quick Start

1.  **Create the Docker Config for `rclone.conf`**:
    On your Swarm manager node, create a Docker config from your `rclone.conf` file.
    ```sh
    docker config create rclone_conf_v1 /path/to/your/rclone.conf
    ```

2.  **Create Docker Secrets for S3 Credentials**:
    Create Docker secrets for the S3 access key and secret key.
    ```sh
    printf "YOUR_S3_ACCESS_KEY_ID" | docker secret create s3_access_key_id_v1 -
    printf "YOUR_S3_SECRET_ACCESS_KEY" | docker secret create s3_secret_access_key_v1 -
    ```
    *(Replace `YOUR_S3_ACCESS_KEY_ID` and `YOUR_S3_SECRET_ACCESS_KEY` with your actual credentials.)*

3.  **Deploy the Stack**:
    Deploy the stack using the `docker-stack.yml` file provided in this directory.
    ```sh
    docker stack deploy -c docker-stack.yml rclone-stack
    ```

4.  **Access the Service**:
    The `rclone-proxy` service will be running on port `8080` across all nodes in your Swarm cluster that are part of the `proxy-net` network. You will likely need a reverse proxy or load balancer (like Traefik, also deployable on Swarm) to route external traffic to this service.

## File Structure

-   `docker-stack.yml`: The Docker Swarm stack file. It defines the service, network, and how to use the `config` and `secrets`.

## How It Works

-   The `docker-stack.yml` file defines a service called `rclone-proxy`.
-   Instead of mounting a local file, it uses `configs` to securely provide the `rclone.conf` to the service at `/config/rclone/rclone.conf`.
-   It uses `secrets` to securely provide the S3 credentials as environment variables to the container. The secrets are mounted as files in `/run/secrets/`, and the `_FILE` suffix on the environment variable name tells `rclone` to read the value from that file. This is more secure than passing secrets directly as environment variables.
-   The `deploy` key allows you to specify deployment-related configurations, such as the number of replicas.
