#!/bin/bash
set -e

# Default to 10000 if PORT is not set by Render
export PORT=${PORT:-10000}

# Substitute environment variables in nginx.conf
envsubst '${PORT}' < /app/nginx.conf > /etc/nginx/nginx.conf

# Start Nginx in the background
nginx

# Clear any existing Xvfb lock files in case of container restart
rm -f /tmp/.X99-lock

# Start Xvfb in the background for dummy display
Xvfb :99 -screen 0 1024x768x24 &
export DISPLAY=:99

# Give Xvfb a moment to start
sleep 2

# Start P.R.A.G.O.N main application
echo "Starting P.R.A.G.O.N..."
exec python run_pragon_moss.py
