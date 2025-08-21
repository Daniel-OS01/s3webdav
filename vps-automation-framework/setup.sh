#!/bin/bash

# ##################################################
# Modular Docker Automation Framework - Main Entry Point
# ##################################################

# --- Configuration ---
# Determine the directory where the script is located, and set paths relative to it.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
MODULES_DIR="$SCRIPT_DIR/modules"
ANALYSIS_SCRIPT="$SCRIPT_DIR/analyze_vps.sh"
TROUBLESHOOT_SCRIPT="$SCRIPT_DIR/troubleshoot.sh"

# --- Helper Functions ---
source "$SCRIPT_DIR/helpers.sh"

# --- Main Functions ---

run_vps_analysis() {
    print_header "VPS Analysis"
    if [ -f "$ANALYSIS_SCRIPT" ]; then
        # Ensure analysis script is executable
        chmod +x "$ANALYSIS_SCRIPT"
        # Run the analysis
        "$ANALYSIS_SCRIPT"
    else
        color_red "ERROR: Analysis script '$ANALYSIS_SCRIPT' not found."
        exit 1
    fi
}

show_service_menu() {
    print_header "Service Module Selection"

    if [ ! -d "$MODULES_DIR" ] || [ -z "$(ls -A "$MODULES_DIR")" ]; then
        color_red "No service modules found in the '$MODULES_DIR' directory."
        exit 1
    fi

    local options=()
    local module_files=()

    # Scan for modules
    for module_file in "$MODULES_DIR"/*.sh; do
        if [ -f "$module_file" ]; then
            MODULE_NAME=$(grep -oP '(?<=^MODULE_NAME=")[^"]*' "$module_file")
            if [ -n "$MODULE_NAME" ]; then
                options+=("$MODULE_NAME")
                module_files+=("$module_file")
            fi
        fi
    done

    local choice_index
    # Handle interactive vs. non-interactive mode
    if [ -t 0 ]; then
        # Interactive mode: use select menu
        options+=("Quit")
        PS3="Please choose a service to configure: "
        select opt in "${options[@]}"; do
            for i in "${!options[@]}"; do
                if [[ "${options[$i]}" == "$opt" ]]; then
                    if [ "$opt" == "Quit" ]; then
                        echo "Exiting."
                        return
                    fi
                    choice_index=$i
                    break 2 # Break out of both loops
                fi
            done
            color_red "Invalid option $REPLY. Please try again."
        done
    else
        # Non-interactive mode: use read
        echo "Please choose a service to configure:"
        for i in "${!options[@]}"; do
            printf "%d) %s\n" "$((i+1))" "${options[$i]}"
        done
        read -r choice
        choice_index=$((choice-1))
    fi

    # Execute the chosen module
    if [[ -v "module_files[choice_index]" ]]; then
        local selected_module="${module_files[choice_index]}"
        local selected_option="${options[choice_index]}"
        color_green "Executing module: $selected_option"

        source "$selected_module"
        run_module
    else
        color_red "Invalid selection. Exiting."
    fi
}


# --- Script Execution ---

# Step 1: Run VPS Analysis
run_vps_analysis

# Step 2: Show Service Module Menu
show_service_menu

echo
color_green "Setup script finished."
echo
