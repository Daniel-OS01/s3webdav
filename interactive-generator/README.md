# Interactive Configuration Generator

This directory contains an interactive CLI tool to help you generate a customized configuration for the `rclone-proxy` solution.

The script guides you through a series of questions and, based on your answers, creates a ready-to-use set of files, including `docker-compose.yml`, `.env`, and `rclone.conf`.

## Features

-   **Interactive Wizard**: A step-by-step command-line interface that asks for the information it needs.
-   **Guided Setup**: Provides context, examples, and guidance for each configuration step.
-   **Input Validation**: Performs basic checks on your input to prevent common errors.
-   **Security Warnings**: Includes explicit warnings about password strength and storing credentials in plain text.
-   **Dynamic File Generation**: Automatically creates all the necessary files for the `rclone-proxy` solution.

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

3.  **Answer the questions**:
    The script will prompt you for information about your S3 gateway credentials and your WebDAV backend.

4.  **Deploy the generated configuration**:
    After the script finishes, it will create a new directory (default: `rclone-proxy-generated`). Navigate into that directory and start the service.
    ```sh
    cd rclone-proxy-generated
    docker-compose up -d
    ```
    Your `rclone-proxy` service should now be running!

## What it Generates

-   `docker-compose.yml`: A Docker Compose file to run the `rclone-proxy` service.
-   `.env`: An environment file containing your S3 gateway credentials.
-   `rclone.conf`: The rclone configuration file for connecting to your WebDAV backend.

**Note on Security**: The generated `rclone.conf` file contains your WebDAV password in plain text. For production deployments, it is strongly recommended that you generate this file using `rclone config` to ensure your password is encrypted. The script will remind you of this when it finishes.
