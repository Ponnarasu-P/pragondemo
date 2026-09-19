FROM python:3.11-slim

# Install system dependencies required for headless execution and reverse proxy
RUN apt-get update && apt-get install -y \
    nginx \
    gettext-base \
    xvfb \
    libx11-dev \
    libxcb1 \
    libxcursor1 \
    libxrandr2 \
    libxi6 \
    libasound2 \
    libportaudio2 \
    portaudio19-dev \
    python3-tk \
    tk-dev \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Set up application directory
WORKDIR /app

# Copy requirements and install them
COPY requirements.txt .

# Install dependencies (Windows-specific ones will be ignored due to markers)
RUN pip install --no-cache-dir -r requirements.txt

# Create a volume directory for Render persistent disks
RUN mkdir -p /app/data

# Copy the rest of the application
COPY . .

# Ensure entrypoint is executable
RUN chmod +x /app/entrypoint.sh

# Start the application
CMD ["/app/entrypoint.sh"]
