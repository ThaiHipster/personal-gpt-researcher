#!/bin/bash

# Deploy GPT-Researcher to Digital Ocean
# This script assumes you've already created a Digital Ocean Droplet with Docker installed

# Step 1: Make sure Docker and Docker Compose are installed
echo "Checking Docker and Docker Compose installation..."
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose not found. Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Step 2: Create necessary directories for volume mounts
echo "Creating necessary directories..."
mkdir -p my-docs outputs logs

# Step 3: Set up environment variables
echo "Setting up environment variables..."
if [ ! -f .env ]; then
    echo "Creating .env file. Please update it with your API keys."
    cp .env.example .env
    echo "NEXT_PUBLIC_GPTR_API_URL=http://$(curl -s ifconfig.me):8000" >> .env
    echo "Please edit the .env file to add your API keys."
fi

# Step 4: Deploy with Docker Compose
echo "Deploying with Docker Compose..."
docker-compose pull || true
docker-compose build
docker-compose up -d

# Step 5: Show deployment info
echo "Deployment completed!"
echo "Backend API is running at: http://$(curl -s ifconfig.me):8000"
echo "Frontend is running at: http://$(curl -s ifconfig.me):3000"
echo "To view logs, run: docker-compose logs -f"
echo "To stop the application, run: docker-compose down" 