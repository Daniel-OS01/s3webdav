# Modular Docker Automation Framework

This repository contains a modular CLI tool designed to streamline the deployment of Docker-based services on a VPS. The system analyzes the host environment and interactively generates customized Docker Compose configurations tailored for various services and deployment platforms like Coolify and Dokploy.

## Features

-   **VPS Analysis**: Automatically gathers system information to inform deployment decisions.
-   **Modular & Extensible**: Services are defined in self-contained modules, making it easy to add new ones.
-   **Interactive Generation**: A step-by-step wizard guides you through the configuration process.
-   **Platform-Aware**: Optimized outputs for deployment inside Coolify and Dokploy.
-   **Troubleshooting**: Includes a dedicated script to help diagnose common deployment issues.

## Quick Start

1.  **Navigate into the project directory**:
    ```sh
    cd vps-automation-framework
    ```

2.  **Run the setup script**:
    The main entry point will guide you through analyzing your VPS and selecting a service to deploy.
    ```sh
    chmod +x setup.sh
    ./setup.sh
    ```

## Available Service Modules (Version 1)

-   LiteLLM (Full Implementation)
-   Duplicati (Template)
-   Homarr (Template)

---

This project is currently under development. Please check the `docs/` directory for more detailed documentation on the architecture and how to contribute.
