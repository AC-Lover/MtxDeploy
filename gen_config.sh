#!/bin/bash

if ! command -v python3 &> /dev/null; then
    echo "Python3 could not be found, installing..."
    sudo apt update
    sudo apt install -y python3 python3-venv python3-pip
fi

if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate

pip install pyyaml

if [ ! -f "env.yml" ]; then
    cp env.example.yml env.yml
    echo "Created env.yml. Please edit it with your settings."
    exit 0
fi

if command -v docker &> /dev/null; then
    docker network create --driver=bridge --subnet=10.0.0.0/16 edge || true
else
    echo "Warning: Docker not found. Skipping network creation."
fi

python3 src/get_element.py

python3 src/create_config.py

echo "Configuration generated in dist/configs"

LOG_DIR="dist/configs/chat_server/data/synapse/logs"
mkdir -p "$LOG_DIR"
touch "$LOG_DIR/homeserver.log"
chmod 777 "$LOG_DIR/homeserver.log" 
echo "Created homeserver.log with permissions."

DATA_DIR="dist/configs/chat_server/data/synapse"
mkdir -p "$DATA_DIR"
chmod -R 777 "$DATA_DIR"
echo "Set permissions for Synapse data directory."

CONF_DIR="dist/configs/chat_server/matrix_synapse"
if [ -d "$CONF_DIR" ]; then
    chmod -R 777 "$CONF_DIR"
    echo "Set permissions for matrix_synapse directory."
fi

ACME_FILE="dist/configs/edge/acme.json"
mkdir -p "dist/configs/edge"
touch "$ACME_FILE"
chmod 600 "$ACME_FILE"
echo "Created acme.json with 600 permissions."

echo "Setup complete."
