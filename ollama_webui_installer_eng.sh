#!/bin/bash
set -e

echo "=========================================="
echo "  🚀 OLLAMA + OPEN WEBUI INSTALLER (Jetson)"
echo "=========================================="

# --- Check if running as sudo ---
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script with: sudo ./ollama_webui_installer.sh"
  exit 1
fi

# --- Add user to Docker group ---
echo "👤 Adding user to Docker group..."
usermod -aG docker $SUDO_USER || true

# --- Install Jetson container tools ---
echo "📦 Installing Jetson container tools..."
cd /home/$SUDO_USER
if [ ! -d "jetson-containers" ]; then
  sudo -u $SUDO_USER git clone https://github.com/dusty-nv/jetson-containers
fi
cd jetson-containers
sudo -u $SUDO_USER bash install.sh

# --- Check if Stable Diffusion container already exists ---
echo "🧠 Checking for existing Stable Diffusion container..."
if docker ps -a --format '{{.Names}}' | grep -q '^sd_pysiv$'; then
  echo "🧹 Removing old container sd_pysiv..."
  docker stop sd_pysiv || true
  docker rm sd_pysiv || true
fi

# --- Create a new persistent Stable Diffusion container ---
echo "🎨 Creating new container 'sd_pysiv'..."
sudo -u $SUDO_USER jetson-containers run --name sd_pysiv $(autotag stable-diffusion-webui) bash || true

# --- Install Ollama ---
echo "🦙 Installing Ollama..."
sudo -u $SUDO_USER curl -fsSL https://ollama.com/install.sh | sh || true

# --- Run Ollama container ---
echo "🦙 Starting Ollama container..."
if docker ps -a --format '{{.Names}}' | grep -q '^ollama$'; then
  docker stop ollama || true
  docker rm ollama || true
fi
docker run -d --network=host --name ollama --restart always ollama/ollama:latest

# --- Wait for Ollama to start ---
echo "⏳ Waiting for Ollama to be available on port 11434..."
until curl -s http://127.0.0.1:11434 > /dev/null; do sleep 2; done
echo "✅ Ollama is up and running!"

# --- Download a default model (you can change this to llama3:8b, mistral, etc.) ---
echo "⬇️ Downloading model llama3.2:3b..."
sudo -u $SUDO_USER ollama run llama3.2:3b || true

# --- Install Open WebUI ---
echo "💻 Installing Open WebUI..."
if docker ps -a --format '{{.Names}}' | grep -q '^open-webui$'; then
  docker stop open-webui || true
  docker rm open-webui || true
fi
docker run -d --network=host \
  -v /home/$SUDO_USER/open-webui:/app/backend/data \
  -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main

# --- Done ---
echo ""
echo "=========================================="
echo "✅ INSTALLATION COMPLETE!"
echo "Ollama running at:  http://127.0.0.1:11434"
echo "Open WebUI available at:  http://<your_jetson_ip>:8080 or :7860"
echo ""
echo "If Docker commands don’t work without sudo, run:"
echo "  newgrp docker"
echo ""
echo "------------------------------------------"
echo "Check container status with:"
echo "  docker ps"
echo "------------------------------------------"
