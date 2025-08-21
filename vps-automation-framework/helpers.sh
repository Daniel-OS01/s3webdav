#!/bin/bash

# ##################################################
# Helper Functions
#
# This script contains common helper functions that can be
# sourced by other scripts in the framework.
# ##################################################

# --- Color/Formatting Functions ---
color_red() {
    echo -e "\033[0;31m$1\033[0m"
}

color_yellow() {
    echo -e "\033[0;33m$1\033[0m"
}

color_green() {
    echo -e "\033[0;32m$1\033[0m"
}

# Function to print a header to the terminal
print_header() {
    echo
    echo "----------------------------------------"
    echo " $1"
    echo "----------------------------------------"
}

# Function to ask a question and store the answer in a variable.
# Usage: ask_question "Your question" "variable_name" "default_value" "is_required (true/false)"
ask_question() {
    local question=$1
    local var_name=$2
    local default_value=$3
    local is_required=$4
    local prompt="$question"
    if [ -n "$default_value" ]; then
        prompt="$prompt [$default_value]"
    fi
    while true; do
        read -r -p "$prompt: " answer
        if [ -z "$answer" ]; then
            answer="$default_value"
        fi
        if [ "$is_required" = "true" ] && [ -z "$answer" ]; then
            color_red "This field is required. Please provide a value."
        else
            declare "$var_name=$answer"
            break
        fi
    done
}

# Function to ask a secret question (e.g., password)
# Usage: ask_secret "Your question" "variable_name" "is_required (true/false)"
ask_secret() {
    local question=$1
    local var_name=$2
    local is_required=$3
    while true; do
        read -r -sp "$prompt: " answer
        echo
        if [ "$is_required" = "true" ] && [ -z "$answer" ]; then
            color_red "This field is required. Please provide a value."
        else
            declare "$var_name=$answer"
            break
        fi
    done
}
