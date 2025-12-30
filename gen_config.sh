#!/bin/bash

# Ensure Python3 and venv are installed
if ! command -v python3 &> /dev/null; then
    echo "Python3 could not be found, installing..."
    sudo apt update
    sudo apt install -y python3 python3-venv python3-pip
fi

# Create a virtual environment
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

# Activate venv
source venv/bin/activate

# Install requirements (PyYAML is needed)
pip install pyyaml

# Check if env.yml exists
if [ ! -f "env.yml" ]; then
    cp env.example.yml env.yml
    echo "Created env.yml. Please edit it with your settings."
    exit 0
fi

# Create Docker network if it doesn't exist
if command -v docker &> /dev/null; then
    docker network create --driver=bridge --subnet=10.0.0.0/16 edge || true
else
    echo "Warning: Docker not found. Skipping network creation."
fi

python3 src/get_element.py

# Run the generation script directly with python (bypassing uv if complex)
# or install uv if create_config.py relies on it heavily.
# But create_config.py seems to just use standard libs + yaml.
python3 src/create_config.py

echo "Configuration generated in dist/configs"

# --- Post-Generation Setup ---

# Create permissions for Synapse logs
LOG_DIR="dist/configs/chat_server/data/synapse/logs"
mkdir -p "$LOG_DIR"
touch "$LOG_DIR/homeserver.log"
chmod 777 "$LOG_DIR/homeserver.log" # Using 777 to ensure container can write regardless of user
echo "Created homeserver.log with permissions."

# Fix Synapse data directory permissions (UID 991 is standard for Matrix Synapse Docker image)
DATA_DIR="dist/configs/chat_server/data/synapse"
mkdir -p "$DATA_DIR"
# We use sudo chown locally if possible, but since this runs on user machine or server
# and we might not have root or want to use sudo indiscriminately.
# However, for Synapse to write to a bind mount, the directory on host must be writable by UID 991.
# The safest way without sudo is creating it world writable or just 777.
chmod -R 777 "$DATA_DIR"
echo "Set permissions for Synapse data directory."

# Fix permissions for matrix_synapse directory (user request)
CONF_DIR="dist/configs/chat_server/matrix_synapse"
# Ensure directory exists (it should via copy, but safe to check)
if [ -d "$CONF_DIR" ]; then
    chmod -R 777 "$CONF_DIR"
    echo "Set permissions for matrix_synapse directory."
fi

# Create acme.json for Traefik with partial permissions (user will need to ensure secure 600 on server if running as root)
# Note: On many systems, creating it here might be owned by current user.
# Traefik requires 600.
ACME_FILE="dist/configs/edge/acme.json"
mkdir -p "dist/configs/edge"
touch "$ACME_FILE"
chmod 600 "$ACME_FILE"
echo "Created acme.json with 600 permissions."

echo "Setup complete."
