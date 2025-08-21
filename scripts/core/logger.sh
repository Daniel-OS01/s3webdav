#!/bin/bash
# logger.sh
# Provides logging functions for the deployment system.

# --- Colors ---
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'

# --- Log Functions ---

# Log an informational message
log_info() {
    echo -e "${BLUE}[INFO] $(date '+%Y-%m-%d %H:%M:%S'): $1${RESET}"
}

# Log a warning message
log_warn() {
    echo -e "${YELLOW}[WARN] $(date '+%Y-%m-%d %H:%M:%S'): $1${RESET}"
}

# Log an error message
log_error() {
    echo -e "${RED}[ERROR] $(date '+%Y-%m-%d %H:%M:%S'): $1${RESET}" >&2
}

# Log a success message
log_success() {
    echo -e "${GREEN}[SUCCESS] $(date '+%Y-%m-%d %H:%M:%S'): $1${RESET}"
}
