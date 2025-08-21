#!/bin/bash

# ############################################################################
#
# WebDAV to S3 Docker Solutions - Interactive Configuration Generator
#
# This script guides users through creating a customized Docker Compose and
# environment file setup for a WebDAV-to-S3 proxy solution.
#
# ############################################################################

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Helper Functions ---

# Color/Formatting Functions
color_red() {
    echo -e "\033[0;31m$1\033[0m"
}

color_yellow() {
    echo -e "\033[0;33m$1\033[0m"
}

color_green() {
    echo -e "\033[0;32m$1\033[0m"
}

# Function to ask a question and store the answer in a variable.
# Usage: ask_question "Your question" "variable_name" "default_value" "is_required (true/false)"
ask_question() {
    local question=$1
    local var_name=$2
    local default_value=$3
    local is_required=$4
    local prompt="$question"
    if [ -n "$default_value" ]; then
        prompt="$prompt [$default_value]"
    fi
    while true; do
        read -r -p "$prompt: " answer
        if [ -z "$answer" ]; then
            answer="$default_value"
        fi
        if [ "$is_required" = "true" ] && [ -z "$answer" ]; then
            color_red "This field is required. Please provide a value."
        else
            declare "$var_name=$answer"
            break
        fi
    done
}

# Function to ask a secret question (e.g., password)
# Usage: ask_secret "Your question" "variable_name" "is_required (true/false)"
ask_secret() {
    local question=$1
    local var_name=$2
    local is_required=$3
    while true; do
        read -r -sp "$prompt: " answer
        echo
        if [ "$is_required" = "true" ] && [ -z "$answer" ]; then
            color_red "This field is required. Please provide a value."
        else
            declare "$var_name=$answer"
            break
        fi
    done
}


# --- Question & Answer Functions ---

get_platform_selection() {
    echo
    echo "--- Step 1: Platform Selection ---"
    PS3="Select your deployment platform: "
    options=("Docker Compose (Standalone)" "Portainer" "Coolify" "Quit")
    select opt in "${options[@]}"; do
        case $opt in
            "Docker Compose (Standalone)") DEPLOYMENT_PLATFORM="compose"; break;;
            "Portainer") DEPLOYMENT_PLATFORM="portainer"; break;;
            "Coolify") DEPLOYMENT_PLATFORM="coolify"; break;;
            "Quit") exit;;
            *) color_red "Invalid option $REPLY";;
        esac
    done
    echo "Note: Currently, the generated files are standard Docker Compose files."
    echo "Future versions will include platform-specific optimizations."
}

get_domain_setup() {
    echo
    echo "--- Step 2: Domain Setup ---"
    echo "This is optional. If you have a domain name, you can enter it here."
    echo "For production, you would point your domain's DNS A record to your server's IP."
    ask_question "Domain Name (optional)" "DOMAIN_NAME" "" "false"
}

get_security_level() {
    echo
    echo "--- Step 3: Security Level ---"
    PS3="Select a security preset: "
    options=("Basic (S3 auth only)" "Secure (Add Basic Auth layer)" "Quit")
    select opt in "${options[@]}"; do
        case $opt in
            "Basic (S3 auth only)") SECURITY_LEVEL="basic"; break;;
            "Secure (Add Basic Auth layer)")
                SECURITY_LEVEL="secure"
                color_yellow "You have chosen to add an extra layer of HTTP Basic Authentication."
                ask_question "Enter Basic Auth Username" "BASIC_AUTH_USER" "admin" "true"
                ask_secret "Enter Basic Auth Password" "BASIC_AUTH_PASS" "true"
                break;;
            "Quit") exit;;
            *) color_red "Invalid option $REPLY";;
        esac
    done
}

get_resource_profile() {
    echo
    echo "--- Step 4: Resource Allocation ---"
    PS3="Select a usage profile to set resource limits (optional): "
    options=("Light (Personal)" "Medium (Small Team)" "Heavy (Production)" "None" "Quit")
    select opt in "${options[@]}"; do
        case $opt in
            "Light (Personal)")
                CPU_LIMIT="0.5"
                MEM_LIMIT="512M"
                break;;
            "Medium (Small Team)")
                CPU_LIMIT="1"
                MEM_LIMIT="1G"
                break;;
            "Heavy (Production)")
                CPU_LIMIT="2"
                MEM_LIMIT="2G"
                break;;
            "None")
                CPU_LIMIT=""
                MEM_LIMIT=""
                break;;
            "Quit") exit;;
            *) color_red "Invalid option $REPLY";;
        esac
    done
    if [ -n "$CPU_LIMIT" ]; then
        echo "Resource limits set: CPU=$CPU_LIMIT, Memory=$MEM_LIMIT"
    else
        echo "No resource limits will be set."
    fi
}

get_output_directory() {
    echo
    echo "--- Step 5: Output Directory ---"
    echo "Where should the generated files be saved?"
    ask_question "Output directory" "OUTPUT_DIR" "./rclone-proxy-generated" "true"
}

get_s3_credentials() {
    echo
    echo "--- Step 6: S3 Gateway Credentials ---"
    color_yellow "SECURITY: These are the credentials you will use to connect to the rclone S3 gateway."
    color_yellow "Do not use default or easily guessable values. Generate random strings for production."
    ask_question "S3 Access Key ID" "S3_ACCESS_KEY" "my-s3-access-key" "true"
    ask_secret "S3 Secret Access Key" "S3_SECRET_KEY" "true"
}

get_webdav_details() {
    echo
    echo "--- Step 7: WebDAV Backend Details ---"
    echo "Now, let's configure the connection to your existing WebDAV server."

    # Handle interactive vs. non-interactive mode for provider selection
    if [ -t 0 ]; then
        # Interactive mode: use select menu
        PS3="Select your WebDAV provider: "
        options=("Nextcloud/ownCloud" "Koofr" "Generic WebDAV" "Other" "Quit")
        select opt in "${options[@]}"; do
            case $opt in
                "Nextcloud/ownCloud") WEBDAV_VENDOR="nextcloud"; break;;
                "Koofr") WEBDAV_VENDOR="other"; break;;
                "Generic WebDAV") WEBDAV_VENDOR="other"; break;;
                "Other") WEBDAV_VENDOR="other"; break;;
                "Quit") exit;;
                *) color_red "Invalid option $REPLY";;
            esac
        done
    else
        # Non-interactive mode: use read
        echo "Select your WebDAV provider:"
        echo "1) Nextcloud/ownCloud"
        echo "2) Koofr"
        echo "3) Generic WebDAV"
        echo "4) Other"
        read -r provider_choice
        case $provider_choice in
            1) WEBDAV_VENDOR="nextcloud";;
            2) WEBDAV_VENDOR="other";;
            3) WEBDAV_VENDOR="other";;
            4) WEBDAV_VENDOR="other";;
            *) color_red "Invalid choice '$provider_choice'. Exiting."; exit 1;;
        esac
    fi

    # URL validation loop
    while true; do
        ask_question "WebDAV URL" "WEBDAV_URL" "" "true"
        if [[ "$WEBDAV_URL" == http://* ]] || [[ "$WEBDAV_URL" == https://* ]]; then
            break
        else
            color_red "Invalid URL format. It must start with http:// or https://"
        fi
    done

    ask_question "WebDAV Username" "WEBDAV_USER" "" "true"

    # Password validation loop
    while true; do
        ask_secret "WebDAV Password" "WEBDAV_PASS" "true"
        if [ ${#WEBDAV_PASS} -lt 8 ]; then
            color_yellow "WARNING: The password is less than 8 characters long. This is not recommended."
            read -r -p "Do you want to use this password anyway? (y/n) " confirm
            if [ "$confirm" = "y" ]; then
                break
            fi
        else
            break
        fi
    done
}


# --- File Generation ---

generate_files() {
    echo
    echo "--- Generating Files ---"

    # Create output directory
    if [ -d "$OUTPUT_DIR" ]; then
        color_yellow "WARNING: Output directory '$OUTPUT_DIR' already exists. Files may be overwritten."
    else
        echo "Creating output directory: $OUTPUT_DIR"
        mkdir -p "$OUTPUT_DIR"
    fi

    local resource_limits_yaml=""
    if [ -n "$CPU_LIMIT" ]; then
        resource_limits_yaml=$(cat <<- EOL
    deploy:
      resources:
        limits:
          cpus: '$CPU_LIMIT'
          memory: '$MEM_LIMIT'
EOL
)
    fi

    # Generate docker-compose.yml
    cat > "$OUTPUT_DIR/docker-compose.yml" << EOL
version: '3.8'

services:
  rclone-proxy:
    image: rclone/rclone:latest
    container_name: rclone-s3-proxy
    ports:
      - "8080:8080"
    volumes:
      - ./rclone.conf:/config/rclone/rclone.conf:ro
    env_file: .env
    restart: unless-stopped
    command: >
      serve s3 webdav-remote:
      --addr :8080
      --s3-no-check-bucket
      --s3-no-head
      --stats 1m
      --log-level INFO
$resource_limits_yaml
EOL

    # Generate .env file
    cat > "$OUTPUT_DIR/.env" << EOL
# S3 Credentials for the rclone S3 gateway
S3_ACCESS_KEY_ID=$S3_ACCESS_KEY
S3_SECRET_ACCESS_KEY=$S3_SECRET_KEY
EOL

    # Generate rclone.conf
    cat > "$OUTPUT_DIR/rclone.conf" << EOL
# =================================================================
# IMPORTANT: This file was generated with a plain-text password.
# For production use, it is HIGHLY recommended to generate this
# file using 'rclone config' to ensure your password is encrypted.
# =================================================================

[webdav-remote]
type = webdav
url = $WEBDAV_URL
vendor = $WEBDAV_VENDOR
user = $WEBDAV_USER
pass = $WEBDAV_PASS
EOL

    color_green "Files generated successfully in '$OUTPUT_DIR'!"
    echo
    color_yellow "SECURITY WARNING: The generated 'rclone.conf' contains your WebDAV password"
    color_yellow "in plain text. For better security, please run 'rclone config' to create"
    color_yellow "a new configuration with an encrypted password."
    echo

    if [ "$SECURITY_LEVEL" = "secure" ]; then
        color_yellow "NOTE: The 'Secure' security level preset in the Quick Start workflow is a placeholder."
        color_yellow "Adding a Basic Auth layer requires a reverse proxy, which is a more advanced setup."
        color_yellow "Please see the 'traefik-secured' solution in this repository for an example."
        echo
    fi

    # Generate QUICKSTART.md
    cat > "$OUTPUT_DIR/QUICKSTART.md" << EOL
# Quick Start Guide

This guide will help you get your rclone S3 proxy service running.

## 1. Review Configuration

-   **\`docker-compose.yml\`**: This file defines the rclone service.
-   **\`.env\`**: This file contains your S3 gateway credentials. **Keep this file secure.**
-   **\`rclone.conf\`**: This file contains your WebDAV backend credentials. **Keep this file secure.**

## 2. Start the Service

Navigate to this directory in your terminal and run the following command:

\`\`\`sh
docker-compose up -d
\`\`\`

## 3. Access Your S3 Gateway

Your S3-compatible endpoint is now available at: \`http://localhost:8080\`

You can connect to it using an S3 client with the credentials you provided, which are stored in the \`.env\` file.

## 4. Stopping the Service

To stop the service, run:

\`\`\`sh
docker-compose down
\`\`\`
EOL

    # Generate SECURITY_CHECKLIST.md
    cat > "$OUTPUT_DIR/SECURITY_CHECKLIST.md" << EOL
# Basic Security Checklist

This checklist provides a few basic security recommendations for your generated deployment.

-   [ ] **Secure the \`.env\` file**: This file contains your S3 gateway credentials. Ensure it is not publicly accessible and has restrictive file permissions.

-   [ ] **Secure the \`rclone.conf\` file**: This file contains your WebDAV backend credentials. The password is currently in plain text.
    -   **Action**: For better security, regenerate this file using the \`rclone config\` command. This will encrypt your password.

-   [ ] **Review Network Exposure**: The service is exposed on port 8080 on your host machine. Ensure that your firewall rules are configured to restrict access to this port to only trusted IP addresses. For production use, you should place this service behind a reverse proxy like Traefik or Caddy to handle HTTPS.

-   [ ] **Use Strong Credentials**: Ensure the S3 and WebDAV credentials you are using are strong, unique, and not easily guessable.

-   [ ] **Regularly Update**: Keep Docker, Docker Compose, and the \`rclone/rclone\` Docker image up to date to receive the latest security patches.
EOL
}


# --- Workflow Functions ---

# Workflow for the "Quick Start" deployment
run_workflow_quick_start() {
    echo
    color_green "--- Starting Workflow 1: Quick Start (Beginner-Friendly) ---"
    echo

    # Gather information
    get_platform_selection
    get_domain_setup
    get_security_level
    get_resource_profile
    get_output_directory
    get_s3_credentials
    get_webdav_details

    # Generate the files
    generate_files

    echo
    color_green "All done! Your configuration has been generated."
    echo "To start the service, navigate to the '$OUTPUT_DIR' directory and run:"
    echo
    echo "  docker-compose up -d"
    echo
}


# --- Main Menu ---

main_menu() {
    echo
    echo "Welcome to the WebDAV-to-S3 Interactive Configuration Generator!"
    echo "-------------------------------------------------------------"
    color_green "This tool will guide you through creating a custom Docker configuration."
    PS3="Please choose a workflow: "
    options=("Quick Start (Beginner-Friendly)" "Quit")
    select opt in "${options[@]}"; do
        case $opt in
            "Quick Start (Beginner-Friendly)")
                run_workflow_quick_start
                break
                ;;
            "Quit")
                break
                ;;
            *) color_red "Invalid option $REPLY";;
        esac
    done
}


# --- Script Execution ---

main_menu
