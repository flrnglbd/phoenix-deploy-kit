#!/bin/bash

# Build the release on the target serveur
# Store the release in local machine at `.edeliver/releases`
mix edeliver build release production

# Upload the release archive to the specified directory and extracts it
# Start the production server
mix edeliver deploy release to production

# Migrate database schema
mix edeliver migrate production
