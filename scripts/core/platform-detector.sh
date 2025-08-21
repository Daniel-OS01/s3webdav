#!/bin/bash
# platform-detector.sh
# Detects the underlying platform (e.g., Coolify).

# Function to detect if Coolify is installed
detect_coolify() {
    log_info "Checking for Coolify installation..."
    if [ -d "/data/coolify" ]; then
        log_success "Coolify installation detected."
        return 0 # 0 indicates success (found)
    else
        log_warn "Coolify installation not detected."
        return 1 # 1 indicates failure (not found)
    fi
}
