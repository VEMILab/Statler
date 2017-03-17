#!/bin/bash

# Starts the server in the background using the address located 
# in the dev.properties file.

ENV=${1:-dev}

function prop {
    grep "${1}" ${ENV}.properties|cut -d'=' -f2
}

rails server -d -b "$(prop 'app.server.address')" 2>&1 | tee server_log.txt
echo 'The server is now running.'
