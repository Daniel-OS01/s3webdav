#!/bin/bash
# env-manager.sh
# Manages .env files for services.

# Function to create a .env file from a template if it doesn't exist.
#
# @param $1: The name of the service (e.g., "litellm").
# @param $2: The absolute path to the repository root.
create_env_if_missing() {
    local service_name="$1"
    local repo_root="$2"

    local template_path="$repo_root/templates/example.env.template"
    local env_path="$repo_root/deployments/$service_name/.env"
    local service_dir
    service_dir=$(dirname "$env_path")

    log_info "Checking for .env file for service '$service_name'..."

    if [ -f "$env_path" ]; then
        log_success ".env file already exists at '$env_path'. No action taken."
        return 0
    fi

    log_warn ".env file not found. Creating from template."

    if [ ! -f "$template_path" ]; then
        log_error "Environment template file not found at '$template_path'!"
        return 1
    fi

    # Ensure the service directory exists.
    mkdir -p "$service_dir"
    if [ $? -ne 0 ]; then
        log_error "Failed to create service directory at '$service_dir'."
        return 1
    fi

    # Create the new .env file by redirecting the template content.
    cat "$template_path" > "$env_path"
    if [ $? -ne 0 ]; then
        log_error "Failed to create .env file at '$env_path' using 'cat'."
        return 1
    fi

    log_success "Successfully created .env file at '$env_path'."
    log_info "Please review and edit the new .env file with your custom values."
}
