#!/usr/bin/env bash

# ---------------------------------------------------------------------------
#                      --- Deployment and Diagnostics ---
#
# This script contains functions for deploying the services and running
# post-deployment checks.
# ---------------------------------------------------------------------------

# Source the helper functions
# shellcheck source=./helpers.sh
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR/helpers.sh"

# --- Function: deploy_services ---
# Builds and starts all services defined in the docker-compose.yml file.
# Uses the --wait flag to ensure containers are healthy before exiting.
deploy_services() {
  info "Starting the deployment process..."
  info "This may take a few minutes as images are pulled and containers are started."

  if ! docker compose up -d --wait; then
    error "Deployment failed. Please check the output above for errors."
  fi

  success "All services have been deployed successfully."
}

# --- Function: post_deployment_diagnostics ---
# Checks the status of all containers after deployment and provides logs
# for any that have exited.
post_deployment_diagnostics() {
  info "Running post-deployment diagnostics..."
  local services=("homarr" "duplicati" "litellm")
  local all_running=true

  for service in "${services[@]}"; do
    local status
    status=$(docker container inspect -f '{{.State.Status}}' "$service" 2>/dev/null)

    if [ "$status" != "running" ]; then
      warn "Service '${service}' is not running. Current status: ${status:-'not found'}."
      all_running=false
      info "Retrieving logs for '${service}'..."
      docker logs "$service" || true # Use || true to prevent script exit if logs fail
    else
      info "Service '${service}' is running."
    fi
  done

  if [ "$all_running" = false ]; then
    error "One or more services failed to start correctly. Please review the logs above for details."
  else
    success "All services are running as expected."
  fi
}
