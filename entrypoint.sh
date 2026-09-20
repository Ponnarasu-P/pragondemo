#!/bin/bash
set -e

# Default to 10000 if PORT is not set by Render
export PORT=${PORT:-10000}

# Substitute environment variables in nginx.conf
envsubst '${PORT}' < /app/nginx.conf > /etc/nginx/nginx.conf

# Clear any existing Xvfb lock files in case of container restart
rm -f /tmp/.X99-lock

# Start Xvfb in the background for dummy display
Xvfb :99 -screen 0 1024x768x24 &
export DISPLAY=:99

# Inject GEMINI_API_KEY from environment into api_keys.json
if [ -n "$GEMINI_API_KEY" ]; then
  echo "Injecting GEMINI_API_KEY into api_keys.json..."
  mkdir -p api
  echo "{\"gemini_api_key\": \"$GEMINI_API_KEY\"}" > api/api_keys.json
fi

# Start P.R.A.G.O.N main application in the background
echo "Starting P.R.A.G.O.N... (this may take a minute)"
python run_pragon_moss.py &

# Wait for Python to open port 8080 before starting Nginx
echo "Waiting for backend to bind to port 8080..."
while ! python -c "import socket; s = socket.socket(); s.settimeout(1); s.connect(('127.0.0.1', 8080)); s.close()" 2>/dev/null; do
  sleep 2
done

echo "Backend is ready! Starting Nginx..."
# Start Nginx in the foreground so the container stays alive
exec nginx -g 'daemon off;'
