#!/bin/bash

# Starts the server in the background using the address located 
# in the dev.properties file.

ENV=${1:-dev}

function prop {
    grep "${1}" ${ENV}.properties|cut -d'=' -f2
}

echo "Starting the server..."

# Generate secrets file if it doesn't exist
if [ ! -f ./config/secrets.yml ]; then
    echo "Secrets file not found. Generating..."
    bash ./make_secrets.sh
fi

# Abort if the dev.properties file does not exist
if [ ! -f ./dev.properties ]; then
    echo "'./dev.properties' not found! Setting up from template."
    cp ./template.properties ./dev.properties
    echo "Make sure to fill in the address you want this server to reside on, then run this command again."
    exit
fi

# Abort if the dev.properties file is not configured
if [ "$(prop 'app.server.address')" = "YOUR_ADDRESS_HERE"]; then
    echo "The address in './dev.properties' is not configured. Please fill this in and run this command again."
    exit
fi

set -e
# Start the rails server in the background using the given IP address
rails server -d -b "$(prop 'app.server.address')" 2>&1 | tee server_log.txt
set +e

echo 'The server is now running.'
