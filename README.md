# VPS Docker Deployment Automation System

This repository contains a comprehensive automation system for deploying Dockerized services to a Virtual Private Server (VPS), with a special focus on the Coolify platform. The system is designed to be modular, user-friendly, and robust.

## Core Features

- **Modular Architecture**: The system is built with a modular bash script architecture, making it easy to extend and maintain.
- **Coolify Optimized**: Includes specific optimizations for deploying to the Coolify platform, including automatic Traefik label generation and environment variable injection.
- **LiteLLM Support**: Provides a dedicated service module for deploying LiteLLM with all its required components (PostgreSQL, Redis).
- **Interactive CLI**: A step-by-step interactive CLI guides the user through the deployment process.
- **VPS Analysis**: The system starts by analyzing the VPS to gather system information and check for prerequisites.
- **Error Handling**: Robust error handling and logging are built-in to help with troubleshooting.

## Project Structure

The project is organized into the following main directories:

- `/scripts`: Contains all the bash scripts for the CLI and modules.
- `/templates`: Contains templates for Docker Compose files, service configurations, and environment variables.
- `/services`: Contains service-specific deployment logic.

## Getting Started

To start the deployment process, simply run the main `deploy.sh` script:

```bash
./deploy.sh
```
