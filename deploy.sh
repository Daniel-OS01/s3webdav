#!/bin/bash
# Main entry point for the deployment system.

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Execute the main script
bash "$SCRIPT_DIR/scripts/main.sh" "$@"
