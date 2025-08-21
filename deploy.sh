#!/usr/bin/env bash

# ===========================================================================
#                Autonomous Services Stack Deployment Script
#
# This script automates the deployment of the service stack, including
# pre-flight checks, environment configuration, and post-deployment
# diagnostics. It is the single entry point for the project.
#
# Usage: ./deploy.sh
# ===========================================================================

# --- Script Configuration ---
# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error when substituting.
# Pipestatus is non-zero if any command in a pipeline fails.
set -euo pipefail

# --- Source Helper Scripts ---
# Load all modular functions from the /scripts/ directory.
# This uses dirname "$0" to ensure the script can be run from any location.
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR/scripts/helpers.sh"
source "$SCRIPT_DIR/scripts/pre-flight.sh"
source "$SCRIPT_DIR/scripts/deployment.sh"

# --- Main Function ---
# Orchestrates the entire deployment process.
main() {
  info "--- Starting Autonomous Services Stack Deployment ---"

  # Run all pre-flight checks to ensure the environment is ready.
  check_prerequisites
  configure_environment
  # Load environment variables from .env file for the script's context
  set -a
  # shellcheck source=.env
  source .env
  set +a
  check_ports

  # Deploy the services and run diagnostics.
  deploy_services
  post_deployment_diagnostics

  success "--- Deployment Complete ---"
  info "All services are up and running. You can access them at the URLs you configured."
}

# --- Execute Main Function ---
# Pass all script arguments to the main function.
main "$@"
