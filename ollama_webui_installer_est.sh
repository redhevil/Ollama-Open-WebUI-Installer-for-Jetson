#!/bin/bash
set -e

echo "=========================================="
echo "  🚀 OLLAMA + OPEN WEBUI INSTALLER (Jetson)"
echo "=========================================="

# --- Kontrollime, et skript jookseks sudo all ---
if [ "$EUID" -ne 0 ]; then
  echo "❌ Palun käivita skript käsuga: sudo ./ollama_webui_installer.sh"
  exit 1
fi

# --- Lisa kasutaja Docker gruppi ---
echo "👤 Lisame kasutaja Docker gruppi..."
usermod -aG docker $SUDO_USER || true

# --- Installi Jetson konteineri tööriistad ---
echo "📦 Installime Jetson konteineritööriistad..."
cd /home/$SUDO_USER
if [ ! -d "jetson-containers" ]; then
  sudo -u $SUDO_USER git clone https://github.com/dusty-nv/jetson-containers
fi
cd jetson-containers
sudo -u $SUDO_USER bash install.sh

# --- Kontrollime, kas stable diffusion konteiner juba eksisteerib ---
echo "🧠 Kontrollime Stable Diffusion konteinerit..."
if docker ps -a --format '{{.Names}}' | grep -q '^sd_pysiv$'; then
  echo "🧹 Eemaldame vana konteineri sd_pysiv..."
  docker stop sd_pysiv || true
  docker rm sd_pysiv || true
fi

# --- Loo uus püsiv Stable Diffusion konteiner ---
echo "🎨 Loome uue konteineri 'sd_pysiv'..."
sudo -u $SUDO_USER jetson-containers run --name sd_pysiv $(autotag stable-diffusion-webui) bash || true

# --- Installime Ollama ---
echo "🦙 Installime Ollama..."
sudo -u $SUDO_USER curl -fsSL https://ollama.com/install.sh | sh || true

# --- Käivitame Ollama konteineri ---
echo "🦙 Käivitame Ollama konteineri..."
if docker ps -a --format '{{.Names}}' | grep -q '^ollama$'; then
  docker stop ollama || true
  docker rm ollama || true
fi
docker run -d --network=host --name ollama --restart always ollama/ollama:latest

# --- Ootame, kuni Ollama käivitub ---
echo "⏳ Ootame, kuni Ollama port 11434 on saadaval..."
until curl -s http://127.0.0.1:11434 > /dev/null; do sleep 2; done
echo "✅ Ollama töötab!"

# --- Laeme alla mudeli (võid hiljem muuta näiteks: llama3:8b, mistral jne) ---
echo "⬇️ Laeme alla mudeli llama3.2:3b..."
sudo -u $SUDO_USER ollama run llama3.2:3b || true

# --- Installime Open WebUI ---
echo "💻 Installime Open WebUI..."
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

# --- Lõpp ---
echo ""
echo "=========================================="
echo "✅ INSTALL LÕPETATUD!"
echo "Ollama töötab:  http://127.0.0.1:11434"
echo "Open WebUI töötab:  http://<sinu_jetsoni_ip>:8080 või 7860"
echo ""
echo "Kui Docker-käsud ei tööta ilma sudo-ta, tee veel käsud:"
echo "  newgrp docker"
echo ""
echo "------------------------------------------"
echo "Kontrolli konteinerite staatust:"
echo "  docker ps"
echo "------------------------------------------"
