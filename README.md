# 🦙 Ollama + Open WebUI Installer for Jetson

This guide explains how to **automatically install and set up Ollama + Open WebUI** on NVIDIA Jetson devices using the provided installation script.

---

## 🚀 1. Download the installer script

Give it execution permission:

```bash
chmod +x ollama_webui_installer_eng.sh
```

---

## ⚙️ 2. Run the installer

Execute the installer with `sudo`:

```bash
sudo ./ollama_webui_installer_eng.sh
```

---

## 🧠 3. When the first installation part (Stable Diffusion container) finishes

You will see something like this:

```
Digest: sha256:b7cd2a48c609a67a56c2e7b9ffbda0368ce1841a8574135fdbe6d4c822640b03
Status: Downloaded newer image for dustynv/stable-diffusion-webui:r36.4.0
root@ubuntu:/# exit
exit
```

Type:

```
exit
```

to continue the installation process.

---

## 🦙 4. During the Ollama installation

You might see a chat interface appear (this means the model has started successfully).  
You can test it by typing:

```
>>> Hi
Hello! How can I assist you today?
```

Then exit the model by typing:

```
>>> /bye
```

This will let the script continue automatically to the next stage.

---

## 💻 5. The installer will then automatically install **Open WebUI**

This connects directly to Ollama and gives you a browser-based interface.

---

## ✅ After Installation

- **Ollama API:**  
  http://127.0.0.1:11434

- **Open WebUI:**  
  http://<your_jetson_ip>:8080  
  *(or sometimes :7860 depending on your configuration)*

---

## 🔍 Checking running containers

You can verify that everything is running with:

```bash
docker ps
```

You should see something similar to:

```
CONTAINER ID   IMAGE                                STATUS          NAMES
a1b2c3d4e5f6   ollama/ollama:latest                 Up 5 minutes    ollama
b7c8d9e0f1a2   ghcr.io/open-webui/open-webui:main   Up 3 minutes    open-webui
```

---

## 🧩 Notes

- If Docker commands do not work without `sudo`, run:

```bash
newgrp docker
```

- You can customize the model by editing this line in the script:

```bash
ollama run llama3.2:3b
```

For example, change it to `llama3:8b` or `mistral`.

---

## 🧰 Optional: Manual container management

If you ever need to stop or remove containers manually:

```bash
docker stop ollama open-webui
docker rm ollama open-webui
```

---

### 🧾 Credits

- **Jetson Containers:** https://github.com/dusty-nv/jetson-containers  
- **Ollama:** https://ollama.com  
- **Open WebUI:** https://github.com/open-webui/open-webui  

---

🟢 *Tested and working on Jetson Orin Nano / Xavier NX (JetPack 6.x)*
