#!/bin/bash
# error-handler.sh
# Provides error handling and trapping.

# This function is called when a command fails.
# It prints a detailed error message and exits.
error_handler() {
  local exit_code=$?
  local line_number=$1
  local command="$2"
  log_error "An error occurred on line $line_number in command: $command"
  log_error "The script will now exit."
  exit $exit_code
}

# This function sets up the error trapping.
# It should be called at the beginning of the main script.
setup_error_trapping() {
    # Exit immediately if a command exits with a non-zero status.
    set -e
    # Treat unset variables as an error when substituting.
    set -u
    # Pipelines return the exit status of the last command that failed.
    set -o pipefail
    # The ERR trap is inherited by functions, command substitutions, and subshells
    set -o errtrace
    # Trap the ERR signal and call the error_handler function.
    # The BASH_COMMAND variable contains the command that was executed.
    trap 'error_handler ${LINENO} "$BASH_COMMAND"' ERR
}
