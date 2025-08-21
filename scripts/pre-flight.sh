#!/usr/bin/env bash

# ---------------------------------------------------------------------------
#                      --- Pre-flight Checks ---
#
# This script contains functions that run before deployment to ensure
# the environment is set up correctly.
# ---------------------------------------------------------------------------

# Source the helper functions
# shellcheck source=./helpers.sh
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR/helpers.sh"

# --- Function: check_prerequisites ---
# Verifies that Docker and Docker Compose are installed and that the Docker
# daemon is responsive.
check_prerequisites() {
  info "Checking for prerequisites..."

  if ! command -v docker &>/dev/null; then
    error "Docker is not installed. Please install Docker before running this script."
  fi

  if ! docker compose version &>/dev/null; then
    error "Docker Compose is not available. Please ensure 'docker compose' (v2) is installed."
  fi

  if ! docker info &>/dev/null; then
    error "The Docker daemon is not running or the current user does not have permission to access it. Please start Docker and try again."
  fi

  success "All prerequisites are met."
}

# --- Function: configure_environment ---
# Checks for the existence of the .env file and provides guidance if it's
# missing.
configure_environment() {
  info "Checking for .env file..."

  if [ ! -f ".env" ]; then
    warn "The .env file was not found."
    info "Copying .env.example to .env. Please edit the .env file to add your secrets."
    if ! cp .env.example .env; then
      error "Failed to copy .env.example to .env. Please do it manually."
    fi
    info "After editing, re-run this script to continue the deployment."
    exit 1 # Exit so the user can edit the file
  fi

  success ".env file found."
}

# --- Function: check_ports ---
# Checks if the ports required by the services are already in use by other Docker containers.
check_ports() {
  info "Checking for port conflicts with other Docker containers..."
  local required_ports=("${HOMARR_PORT:-7575}" "8200" "4000")
  local port_in_use=false

  for port in "${required_ports[@]}"; do
    # Check if any running container is already publishing the port
    if docker ps --filter "publish=${port}" --format '{{.ID}}' | grep -q .; then
      local container_name
      container_name=$(docker ps --filter "publish=${port}" --format '{{.Names}}')
      warn "Port ${port} is already in use by container: ${container_name}."
      port_in_use=true
    fi
  done

  if [ "$port_in_use" = true ]; then
    error "One or more required ports are already in use by other containers. Please stop the conflicting containers or change the ports in the .env file."
  fi

  success "All required ports are available."
}
