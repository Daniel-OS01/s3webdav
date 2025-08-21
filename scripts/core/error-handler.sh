#!/bin/bash
# error-handler.sh
# Provides error handling and trapping.

# This function is called when a command fails.
# It prints a detailed error message.
error_handler() {
  local exit_code=$?
  local line_number=$1
  local command="$2"
  # We are not exiting here, just logging the error as requested.
  log_error "A non-fatal error occurred on line $line_number in command: '$command' (Exit Code: $exit_code)"
}

# This function sets up the error trapping.
setup_error_trapping() {
    # The ERR trap is inherited by functions, command substitutions, and subshells
    set -o errtrace
    # Trap the ERR signal and call the error_handler function.
    # The BASH_COMMAND variable contains the command that was executed.
    trap 'error_handler ${LINENO} "$BASH_COMMAND"' ERR
}
