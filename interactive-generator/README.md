# Interactive Configuration Generator

This directory contains an interactive CLI tool to help you generate a customized configuration for various deployment scenarios.

The script uses a workflow-based approach to tailor the generated files to your specific needs, from simple personal projects to more complex production deployments.

## Workflows

Currently, the following workflow is available:

-   **Quick Start (Beginner-Friendly)**: A simple, step-by-step guide to get a basic `rclone-proxy` service running with minimal configuration.

More workflows for advanced and production use cases will be added in the future.

## Features

-   **Workflow-Based**: Choose a workflow that matches your use case.
-   **Interactive Wizard**: A step-by-step command-line interface that asks for the information it needs.
-   **Guided Setup**: Provides context, examples, and guidance for each configuration step.
-   **Input Validation**: Performs basic checks on your input to prevent common errors.
-   **Dynamic File Generation**: Automatically creates a complete package of files based on your choices.

## Prerequisites

-   A `bash` shell (standard on Linux and macOS, available on Windows via WSL or Git Bash).
-   `docker` and `docker-compose` installed on your machine.

## How to Use

1.  **Navigate to this directory**:
    ```sh
    cd interactive-generator
    ```

2.  **Run the script**:
    The script is already marked as executable.
    ```sh
    ./generate_config.sh
    ```

3.  **Choose a workflow**:
    Select the "Quick Start" workflow from the menu.

4.  **Answer the questions**:
    The script will prompt you for information about your platform, security preferences, and backend credentials.

5.  **Deploy the generated configuration**:
    After the script finishes, it will create a new directory (default: `rclone-proxy-generated`). This directory contains everything you need to get started. Follow the instructions in the generated `QUICKSTART.md` file.

## What the "Quick Start" Workflow Generates

-   `docker-compose.yml`: A Docker Compose file to run the `rclone-proxy` service, customized with your resource settings.
-   `.env`: An environment file containing your S3 gateway credentials.
-   `rclone.conf`: The rclone configuration file for connecting to your WebDAV backend.
-   `QUICKSTART.md`: A simple guide with copy-paste commands to get your service running.
-   `SECURITY_CHECKLIST.md`: A basic checklist of security best practices to review after deployment.
