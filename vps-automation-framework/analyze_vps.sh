#!/bin/bash

# ##################################################
# VPS Analysis Module
#
# This script gathers system information and saves it to a log file.
# The analysis results can be used by other modules.
# ##################################################

# --- Configuration ---
LOG_FILE="vps_analysis.txt"

# --- Helper Functions ---
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/helpers.sh"

# Function to print a header to the terminal AND the log file
print_and_log_header() {
    echo "----------------------------------------" | tee -a "$LOG_FILE"
    echo " $1" | tee -a "$LOG_FILE"
    echo "----------------------------------------" | tee -a "$LOG_FILE"
}

# Function to run a command and append its output to the log file
# It also prints the output to the terminal.
run_and_log() {
    echo "=> Running: $@"
    echo "---" >> "$LOG_FILE"
    echo "Command: $@" >> "$LOG_FILE"
    "$@" | tee -a "$LOG_FILE"
    echo >> "$LOG_FILE" # Add a newline for spacing
    echo
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- Main Execution ---

# Clear the log file for a fresh analysis
echo "VPS Analysis Report - $(date)" > "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"
echo

echo "Starting VPS analysis..."
echo "Results will be saved to '$LOG_FILE'"
echo

# 1. OS Information
print_and_log_header "Operating System"
run_and_log cat /etc/os-release

# 2. CPU Information
print_and_log_header "CPU Information"
run_and_log lscpu

# 3. Memory Usage
print_and_log_header "Memory Usage"
run_and_log free -h

# 4. Disk Space
print_and_log_header "Disk Space"
run_and_log df -h

# 5. Docker & Docker Compose Versions
print_and_log_header "Docker & Docker Compose"
if command_exists docker; then
    run_and_log docker --version
    if command_exists docker compose; then
        run_and_log docker compose version
    else
        echo "WARNING: 'docker compose' command not found. Docker Compose V2 might not be installed." | tee -a "$LOG_FILE"
    fi
else
    echo "ERROR: Docker does not seem to be installed. Please install Docker to proceed." | tee -a "$LOG_FILE"
fi

# 6. Network Information
print_and_log_header "Network Interfaces"
run_and_log ip -br a

# 7. Open Ports
print_and_log_header "Open Ports (Listening)"
if command_exists ss; then
    run_and_log ss -tuln
else
    echo "WARNING: 'ss' command not found. Trying 'netstat'." | tee -a "$LOG_FILE"
    if command_exists netstat; then
        run_and_log netstat -tuln
    else
        echo "ERROR: Neither 'ss' nor 'netstat' found. Cannot list open ports." | tee -a "$LOG_FILE"
    fi
fi

# 8. Firewall Status
print_and_log_header "Firewall Status"
if command_exists ufw; then
    # ufw status requires sudo. We check for non-interactive sudo access first.
    if sudo -n true 2>/dev/null; then
        echo "=> Checking UFW status with sudo..."
        if sudo ufw status | grep -q "Status: active"; then
            echo "UFW firewall is active." | tee -a "$LOG_FILE"
            # Use 'tee' with 'sudo' correctly by piping to it
            sudo ufw status verbose | tee -a "$LOG_FILE"
        else
            echo "UFW firewall is inactive." | tee -a "$LOG_FILE"
        fi
    else
        echo "WARNING: Could not run 'ufw status' without a password. Skipping firewall check." | tee -a "$LOG_FILE"
        echo "Suggestion: Run this script with 'sudo ./analyze_vps.sh' for a complete report." | tee -a "$LOG_FILE"
    fi
else
    echo "WARNING: 'ufw' command not found. Cannot check firewall status." | tee -a "$LOG_FILE"
fi

echo
echo "----------------------------------------"
echo "VPS analysis complete."
echo "Full report saved to '$LOG_FILE'."
echo "----------------------------------------"
