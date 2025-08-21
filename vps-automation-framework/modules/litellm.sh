#!/bin/bash

# ##################################################
# Service Module: LiteLLM
#
# This module generates a Docker Compose setup for LiteLLM,
# an OpenAI-compatible API server.
# ##################################################

# --- Module Metadata ---
MODULE_NAME="LiteLLM - OpenAI-Compatible API Server"

# --- Helper Functions ---
# This module assumes that helper functions like 'color_green' and 'ask_question'
# have already been sourced by the main 'setup.sh' script.

# --- Module-specific Functions ---

generate_litellm_config() {
    local config_path=$1
    local model_name="gpt-3.5-turbo" # Example model

    echo "Generating LiteLLM config file at $config_path/config.yaml"
    mkdir -p "$config_path"

    # Using a heredoc with a variable for the model name
    cat > "$config_path/config.yaml" << EOL
# LiteLLM Configuration File
# For more details, see: https://docs.litellm.ai/docs/proxy/config

model_list:
  - model_name: $model_name
    litellm_params:
      model: openai/gpt-3.5-turbo
      api_key: \${OPENAI_API_KEY} # Reads from environment variable

litellm_settings:
  # set to 'DEBUG' to see detailed logs
  log_level: "INFO"
EOL
}

# --- Main Module Function ---

run_module() {
    color_green "--- Configuring LiteLLM ---"

    # --- Interactive Questions ---

    # Platform Selection
    PS3="Select your deployment platform: "
    options=("Standard Docker Compose" "Coolify / Dokploy" "Quit")
    select opt in "${options[@]}"; do
        case $opt in
            "Standard Docker Compose") PLATFORM="compose"; break;;
            "Coolify / Dokploy") PLATFORM="coolify_dokploy"; break;;
            "Quit") exit;;
            *) color_red "Invalid option $REPLY";;
        esac
    done

    ask_question "Enter the path for LiteLLM config files" "LITELLM_CONFIG_PATH" "./litellm_data/config" "true"
    ask_secret "Enter your OpenAI API Key (will be stored in .env)" "OPENAI_KEY" "true"

    if [ "$PLATFORM" == "compose" ]; then
        ask_question "Expose LiteLLM on which host port?" "LITELLM_PORT" "8000" "true"
    else
        ask_question "What domain will LiteLLM be served on (e.g., litellm.your.domain)?" "LITELLM_DOMAIN" "" "true"
    fi

    local run_ui="false"
    read -r -p "Do you want to run the optional LiteLLM UI? (y/n) " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        run_ui="true"
        if [ "$PLATFORM" == "compose" ]; then
            ask_question "Expose LiteLLM UI on which host port?" "LITELLM_UI_PORT" "8001" "true"
        else
            ask_question "What domain will the UI be served on (e.g., litellm-ui.your.domain)?" "LITELLM_UI_DOMAIN" "" "true"
        fi
    fi

    # --- File Generation ---

    # Define output directory relative to the main project folder
    local output_dir="$SCRIPT_DIR/../litellm-deployment"
    echo
    echo "Generating LiteLLM deployment files in '$output_dir/'..."
    mkdir -p "$output_dir"

    # Generate litellm_config.yaml
    generate_litellm_config "$output_dir/config"

    # Generate .env file
    cat > "$output_dir/.env" << EOL
# Environment variables for LiteLLM
OPENAI_API_KEY=$OPENAI_KEY
EOL

    # --- Dynamic Docker Compose Generation ---

    # Based on the platform selection, we dynamically generate either the 'ports' section
    # for standard Docker Compose or a 'labels' section for Traefik-based platforms
    # like Coolify and Dokploy.
    local proxy_ports_or_labels=""
    if [ "$PLATFORM" == "compose" ]; then
        proxy_ports_or_labels="    ports:\n      - \"$LITELLM_PORT:8000\""
    else
        proxy_ports_or_labels=$(cat <<-EOL
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.litellm-proxy.rule=Host(\`$LITELLM_DOMAIN\`)"
      - "traefik.http.services.litellm-proxy.loadbalancer.server.port=8000"
EOL
)
    fi

    # Conditionally generate the YAML for the LiteLLM UI service if the user opted in.
    local ui_service_yaml=""
    if [ "$run_ui" == "true" ]; then
        local ui_ports_or_labels=""
        # The UI service also needs platform-aware network configuration.
        if [ "$PLATFORM" == "compose" ]; then
            ui_ports_or_labels="    ports:\n      - \"$LITELLM_UI_PORT:4000\""
        else
            ui_ports_or_labels=$(cat <<-EOL
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.litellm-ui.rule=Host(\`$LITELLM_UI_DOMAIN\`)"
      - "traefik.http.services.litellm-ui.loadbalancer.server.port=4000"
EOL
)
        fi

        ui_service_yaml=$(cat <<- EOL

  litellm-ui:
    image: ghcr.io/litellm/ui:stable
$ui_ports_or_labels
    depends_on:
      - litellm-proxy
    environment:
      - LITELLM_PROXY_URL=http://litellm-proxy:8000
    restart: unless-stopped
EOL
)
    fi

    cat > "$output_dir/docker-compose.yml" << EOL
version: '3.8'

services:
  litellm-proxy:
    image: ghcr.io/berriai/litellm:main-latest
$proxy_ports_or_labels
    volumes:
      - ./config:/app/config.yaml
    env_file: .env
    restart: unless-stopped
    command: ["--config", "/app/config.yaml", "--detailed_debug"]
$ui_service_yaml
EOL

    color_green "LiteLLM configuration generated successfully!"
    echo "To start, run: cd $output_dir && docker-compose up -d"
    echo
    if [ "$PLATFORM" != "compose" ]; then
        color_yellow "NOTE: The 'ports' section was omitted. Deploy this stack in Coolify/Dokploy and configure the domain(s) in their UI."
    fi
}
