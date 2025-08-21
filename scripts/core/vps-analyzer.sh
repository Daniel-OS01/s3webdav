#!/bin/bash
# vps-analyzer.sh
# Gathers basic VPS system information.

# Function to get OS information
get_os_info() {
    if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    else
        # Fallback
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    echo "OS: $OS $VER"
}

# Function to get system architecture
get_arch() {
    echo "Architecture: $(uname -m)"
}

# Function to get CPU information
get_cpu_info() {
    echo "CPU Info: $(lscpu | grep 'Model name' | sed 's/Model name:[ \t]*//')"
    echo "CPU Cores: $(nproc)"
}

# Function to get memory information
get_mem_info() {
    echo "Memory Info:"
    free -h
}

# Main function for the analyzer
analyze_vps() {
    echo "--- System Analysis ---"
    get_os_info
    get_arch
    get_cpu_info
    get_mem_info
    echo "-----------------------"
}
