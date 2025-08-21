#!/bin/bash

# ##################################################
# Troubleshooting Module
#
# This script helps diagnose common issues with Docker deployments,
# networking, and proxy configurations by comparing the live
# system state against the baseline from 'vps_analysis.txt'.
# ##################################################

# --- Configuration ---
LOG_FILE="vps_analysis.txt"
DEPLOYMENT_DIR="." # Default to current directory

# --- Helper Functions ---
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/helpers.sh"

# --- Diagnostic Functions ---

check_docker_status() {
    print_header "Checking Docker Service"
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        color_green "✅ Docker service is running."
    else
        color_red "❌ ERROR: Docker service is not running or not installed."
        echo "Suggestion: Start the Docker service with 'sudo systemctl start docker' or ensure it is installed correctly."
        exit 1
    fi
}

check_running_containers() {
    print_header "Checking Running Containers"
    echo "Listing all running Docker containers..."
    if [ -z "$(docker ps -q)" ]; then
        color_yellow "No containers are currently running."
    else
        docker ps
    fi
}

check_port_conflicts() {
    local compose_file="$1"
    print_header "Checking for Port Conflicts in '$compose_file'"

    if [ ! -f "$compose_file" ]; then
        color_yellow "No '$compose_file' found in this directory. Skipping port check."
        return
    fi

    # Extract mapped host ports from the docker-compose file using a Perl-compatible regex.
    # This looks for lines like "8080:8000" and extracts the host port (the part before the colon).
    ports=$(grep -oP '(?<=")\d+(?=:)' "$compose_file")
    if [ -z "$ports" ]; then
        color_green "No host ports are mapped in '$compose_file'. No conflicts to check."
        return
    fi

    echo "Checking for conflicts on host ports: $ports"
    local has_conflict=0
    for port in $ports; do
        if ss -tuln | grep -q ":$port "; then
            color_red "❌ CONFLICT: Port $port is already in use on the host."
            ss -tulnp | grep ":$port "
            has_conflict=1
        else
            color_green "✅ Port $port is available."
        fi
    done

    if [ $has_conflict -eq 1 ]; then
        echo "Suggestion: Change the port mapping in your '$compose_file' or stop the process using the conflicting port."
    fi
}

compare_with_baseline() {
    print_header "Comparing Live System with Baseline ('$LOG_FILE')"
    if [ ! -f "$LOG_FILE" ]; then
        color_yellow "Baseline file '$LOG_FILE' not found. Skipping comparison."
        return
    fi

    # Example comparison: Docker version
    local baseline_docker_version=$(grep -m 1 "Docker version" "$LOG_FILE" | awk '{print $3}')
    local live_docker_version=$(docker --version | awk '{print $3}')

    echo "Baseline Docker Version: $baseline_docker_version"
    echo "Live Docker Version:     $live_docker_version"

    if [ "$baseline_docker_version" != "$live_docker_version" ]; then
        color_yellow "⚠️  Warning: Docker version has changed since the initial analysis."
    else
        color_green "✅ Docker version matches baseline."
    fi

    # This function can be expanded to compare other baseline metrics,
    # for example, by parsing the output of 'free -h' or 'df -h' from the log file
    # and comparing it with the live output.
}


# --- Main Execution ---

echo "Starting troubleshooting diagnostics..."

# Find the most recent deployment directory to check
if [ -d "litellm-deployment" ]; then
    DEPLOYMENT_DIR="litellm-deployment"
    echo "Found deployment directory: $DEPLOYMENT_DIR"
fi

check_docker_status
check_running_containers
check_port_conflicts "$DEPLOYMENT_DIR/docker-compose.yml"
compare_with_baseline

echo
color_green "Troubleshooting script finished."
