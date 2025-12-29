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

# Run the generation script directly with python (bypassing uv if complex)
# or install uv if create_config.py relies on it heavily.
# But create_config.py seems to just use standard libs + yaml.
python3 src/create_config.py

echo "Configuration generated in dist/configs"
