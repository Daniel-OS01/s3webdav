# rclone-proxy: Kubernetes Deployment

This directory contains Kubernetes manifests to deploy the `rclone-proxy` solution to a Kubernetes cluster.

This setup follows standard Kubernetes practices, using a `ConfigMap` for non-sensitive configuration and a `Secret` for sensitive data.

## Prerequisites

-   A running Kubernetes cluster (e.g., Minikube, GKE, EKS, AKS).
-   `kubectl` configured to connect to your cluster.
-   A valid `rclone.conf` file.

## Quick Start

1.  **Create the Namespace**:
    It's good practice to deploy applications in their own namespace.
    ```sh
    kubectl apply -f namespace.yml
    ```

2.  **Create the `rclone.conf` ConfigMap**:
    You need to create a `ConfigMap` from your `rclone.conf` file. The key in the `ConfigMap` must be `rclone.conf`.
    ```sh
    kubectl create configmap rclone-conf --from-file=rclone.conf=/path/to/your/rclone.conf -n rclone-proxy
    ```

3.  **Create the S3 Credentials Secret**:
    You need to create a `Secret` containing your S3 access key and secret key. The values must be base64-encoded.
    ```sh
    # Replace with your actual credentials
    ACCESS_KEY="YOUR_S3_ACCESS_KEY_ID"
    SECRET_KEY="YOUR_S3_SECRET_ACCESS_KEY"

    kubectl create secret generic s3-credentials \
      --from-literal=S3_ACCESS_KEY_ID=$(echo -n $ACCESS_KEY | base64) \
      --from-literal=S3_SECRET_ACCESS_KEY=$(echo -n $SECRET_KEY | base64) \
      -n rclone-proxy
    ```
    *(Alternatively, you can edit the `secret.yml` file with your base64-encoded credentials and apply it directly.)*

4.  **Deploy the Application**:
    Apply the `deployment.yml` and `service.yml` manifests.
    ```sh
    kubectl apply -f deployment.yml -n rclone-proxy
    kubectl apply -f service.yml -n rclone-proxy
    ```

5.  **Access the Service**:
    The `rclone-proxy` service will be running as a `ClusterIP` service, meaning it's only accessible from within the Kubernetes cluster.
    -   **Service Name**: `rclone-proxy`
    -   **Port**: `8080`

    You can access it from another pod in the same namespace at `http://rclone-proxy:8080`.

    To expose it externally, you would typically use an Ingress controller (like Nginx Ingress or Traefik Ingress) and create an `Ingress` resource.

## File Structure

-   `namespace.yml`: Defines the `rclone-proxy` namespace.
-   `configmap.yml`: An *example* of how the `rclone.conf` `ConfigMap` should be structured. You should create it manually as described above.
-   `secret.yml`: An *example* of how the S3 credentials `Secret` should be structured. You should create it manually as described above for better security.
-   `deployment.yml`: Defines the `Deployment`, which manages the `rclone-proxy` pod. It mounts the `ConfigMap` and `Secret` as volumes and environment variables.
-   `service.yml`: Defines the `Service` that provides a stable endpoint for the `rclone-proxy` deployment within the cluster.
