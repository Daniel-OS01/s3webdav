#!/bin/bash
# Main script for the deployment system.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Source core modules
source "$SCRIPT_DIR/core/logger.sh"
source "$SCRIPT_DIR/core/error-handler.sh"
source "$SCRIPT_DIR/core/vps-analyzer.sh"
source "$SCRIPT_DIR/core/platform-detector.sh"

# Setup error trapping
setup_error_trapping

# Main function
main() {
    log_info "Welcome to the VPS Deployment Automation System!"
    echo

    log_info "Phase 1: System Analysis"
    analyze_vps
    echo

    log_info "Phase 2: Platform Detection"
    if detect_coolify; then
        log_info "Coolify-specific optimizations will be used."
    else
        log_warn "Continuing without Coolify-specific optimizations."
    fi
    echo

    log_info "All checks passed. System is ready."
}

# Call the main function
main "$@"
