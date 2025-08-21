#!/usr/bin/env bash

# ---------------------------------------------------------------------------
#                      --- Helper Functions ---
#
# This script contains utility functions for logging and messaging.
# ---------------------------------------------------------------------------

# Color codes
readonly COLOR_RESET='\033[0m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'

# Logging functions
msg() {
  echo -e "${1-}"
}

info() {
  msg "${COLOR_BLUE}INFO:${COLOR_RESET} ${1}"
}

success() {
  msg "${COLOR_GREEN}SUCCESS:${COLOR_RESET} ${1}"
}

warn() {
  msg "${COLOR_YELLOW}WARNING:${COLOR_RESET} ${1}"
}

error() {
  msg "${COLOR_RED}ERROR:${COLOR_RESET} ${1}" >&2
  exit 1
}
