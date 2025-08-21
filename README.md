# Autonomous Services Stack

This repository contains a self-contained, self-hosted deployment of three Docker Compose services (LiteLLM, Duplicati, and Homarr) with a robust, automated deployment script. The project is designed to be fully operational, secure, and resilient to common deployment errors, making it easy to set up a personal cloud stack with minimal effort.

## Features

- **Automated Deployment**: A single `deploy.sh` script handles everything from checking prerequisites to deploying services and running diagnostics.
- **Resilient by Design**: The script performs pre-flight checks for common issues like port conflicts and missing configurations, providing clear, actionable error messages.
- **Secure by Default**: All sensitive information (API keys, passwords) is managed through a `.env` file, which is excluded from version control, preventing secrets from being leaked.
- **Service Stack**:
    - **Homarr**: A simple, modern, and elegant dashboard for your server.
    - **Duplicati**: A free, open-source backup client to store encrypted backups online.
    - **LiteLLM**: An OpenAI-compatible proxy that simplifies interactions with various Large Language Models (LLMs).

## Prerequisites

Before you begin, ensure you have the following installed on your system:

- **Docker**: The containerization platform used to run the services.
- **Docker Compose (v2)**: The tool for defining and running multi-container Docker applications.

The `deploy.sh` script will automatically verify that these prerequisites are met before proceeding.

## Quick Start Guide

Getting the service stack running is as simple as following these steps:

1.  **Clone the Repository**:
    ```bash
    git clone <repository_url>
    cd autonomous-services-stack
    ```

2.  **Create Your Environment File**:
    The project uses a `.env` file to manage all your secrets and configurations. An example file is provided.
    ```bash
    cp .env.example .env
    ```

3.  **Configure Your Services**:
    Open the `.env` file with a text editor and fill in the required values. This includes API keys for LiteLLM, passwords for Duplicati, and user/group IDs.
    ```bash
    nano .env
    ```
    You will also need to edit `configs/litellm_config.yaml` to set your Azure deployment name.

4.  **Run the Deployment Script**:
    Execute the `deploy.sh` script to start the entire stack.
    ```bash
    chmod +x deploy.sh
    ./deploy.sh
    ```
    The script will guide you through the process, run checks, and deploy all the services.

## Troubleshooting

The `deploy.sh` script has several built-in diagnostic features to help you resolve common issues quickly.

| Error Message (in script output) | Root Cause | How the Script Helps |
| :--- | :--- | :--- |
| `Docker is not installed.` | The `docker` command was not found on your system. | The script stops and instructs you to install Docker before you waste time on a failed deployment. |
| `The Docker daemon is not running...` | Docker is installed but the service isn't active, or you don't have permission to use it. | The script stops and prompts you to start the Docker daemon or fix your user permissions (`sudo usermod -aG docker $USER`). |
| `The .env file was not found.` | You haven't created the `.env` file from the example. | The script automatically copies `.env.example` to `.env` and instructs you to edit it before re-running the script. |
| `Port XXXX is already in use...` | Another application on your host machine is using a port needed by one of the services. | The script checks all required ports before starting the containers and tells you exactly which port is conflicted, so you can resolve it. |
| `Service 'X' is not running...` | A container failed to start correctly after the `docker compose up` command. This is often due to a misconfiguration in the `.env` file (e.g., an invalid API key). | The script automatically detects that the container has exited and immediately prints its logs to the console, giving you the exact error message from within the container so you can diagnose it quickly. |

By following the script's output, you should be able to resolve most deployment issues without manual debugging.
