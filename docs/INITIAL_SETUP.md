# Initial Setup Guide

Complete installation and setup instructions for AI Content Studio.

---

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Prerequisites Installation](#prerequisites-installation)
3. [ComfyUI Setup](#comfyui-setup)
4. [Build MCP Docker Images](#build-mcp-docker-images)
5. [Configure Environment](#configure-environment)
6. [Verify Installation](#verify-installation)

---

## System Requirements

### Minimum Requirements (FFmpeg MCP only)

| Component | Requirement |
|-----------|-------------|
| OS | macOS 13+ / Linux / Windows with WSL2 |
| Docker | Docker Desktop 4.0+ |
| RAM | 8GB |
| Disk | 5GB free space |

### Full Stack Requirements (with AI generation)

| Component | Requirement |
|-----------|-------------|
| OS | macOS 14+ (for Metal acceleration) |
| Processor | Apple M1/M2/M3/M4 or NVIDIA GPU |
| RAM | 16GB+ (24GB recommended) |
| Disk | 50GB+ free space |
| Docker | Docker Desktop 4.0+ |
| Python | Python 3.11+ |

---

## Prerequisites Installation

### macOS

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Docker Desktop
brew install --cask docker

# Install Python 3.11
brew install python@3.11

# Install Git
brew install git

# Install FFmpeg (for local testing)
brew install ffmpeg

# Install jq (for JSON parsing in scripts)
brew install jq
```

### Linux (Ubuntu/Debian)

```bash
# Update packages
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Install Python 3.11
sudo apt install python3.11 python3.11-venv python3-pip

# Install Git
sudo apt install git

# Install FFmpeg
sudo apt install ffmpeg

# Install jq
sudo apt install jq
```

### Windows (WSL2)

```powershell
# Enable WSL2 and install Ubuntu
wsl --install -d Ubuntu

# Install Docker Desktop with WSL2 backend
# Download from: https://www.docker.com/products/docker-desktop
```

Then follow the Linux instructions inside WSL2.

---

## ComfyUI Setup

ComfyUI runs **natively** (not in Docker) for GPU acceleration.

### Step 1: Clone ComfyUI

```bash
cd ~
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
```

### Step 2: Create Virtual Environment

```bash
# Create venv with Python 3.11
python3.11 -m venv venv

# Activate venv
source venv/bin/activate  # macOS/Linux
# or: .\venv\Scripts\activate  # Windows
```

### Step 3: Install PyTorch

**macOS (Metal):**
```bash
pip install --pre torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/nightly/cpu
```

**Linux (NVIDIA CUDA):**
```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
```

**Linux (CPU only):**
```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
```

### Step 4: Install ComfyUI Dependencies

```bash
pip install -r requirements.txt
```

### Step 5: Install AnimateDiff Extension

```bash
cd custom_nodes
git clone https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved.git
cd ComfyUI-AnimateDiff-Evolved
pip install -r requirements.txt
cd ../..
```

### Step 6: Download Required Models

#### Checkpoint Model (required)

Download **Realistic Vision 5.1** (~2.2GB):
- Source: [HuggingFace](https://huggingface.co/SG161222/Realistic_Vision_V5.1_noVAE) or [CivitAI](https://civitai.com/models/4201)
- Place in: `~/ComfyUI/models/checkpoints/`

```bash
# Create directory
mkdir -p ~/ComfyUI/models/checkpoints

# Move downloaded file
mv ~/Downloads/realisticVisionV51_v51VAE.safetensors ~/ComfyUI/models/checkpoints/
```

#### AnimateDiff Motion Module (required for video)

Download **AnimateDiff v3** (~1.7GB):
- Source: [HuggingFace](https://huggingface.co/guoyww/animatediff)
- Place in: `~/ComfyUI/models/animatediff_models/`

```bash
# Create directory
mkdir -p ~/ComfyUI/models/animatediff_models

# Move downloaded file
mv ~/Downloads/mm_sd15_v3.safetensors ~/ComfyUI/models/animatediff_models/
```

### Step 7: Test ComfyUI

```bash
cd ~/ComfyUI
source venv/bin/activate
python main.py
```

Open http://localhost:8188 in your browser. You should see the ComfyUI interface.

---

## Build MCP Docker Images

### Step 1: Navigate to MCPs Directory

```bash
cd ~/Documents/work/AI/mcps
```

### Step 2: Build FFmpeg MCP

```bash
cd ffmpeg-mcp
chmod +x build.sh
./build.sh
cd ..
```

### Step 3: Build ComfyUI MCP

```bash
cd comfyui-mcp
chmod +x build.sh
./build.sh
cd ..
```

### Step 4: Build Utility MCP

```bash
cd utility-mcp
chmod +x build.sh
./build.sh
cd ..
```

### Step 5: Verify Images

```bash
docker images | grep mcp
```

Expected output:
```
ffmpeg-mcp      latest    xxxxx    xxxMB
comfyui-mcp     latest    xxxxx    xxxMB
utility-mcp     latest    xxxxx    xxxMB
```

---

## Configure Environment

### Step 1: Navigate to AI Content Studio

```bash
cd ~/Documents/work/AI/ai-content-studio
```

### Step 2: Create Environment File

```bash
cp .env.example .env
```

### Step 3: Edit Configuration (Optional)

```bash
nano .env
# or: code .env
```

**Important settings to customize:**

```bash
# Change n8n password (required for security)
N8N_PASSWORD=your_secure_password_here

# Set your timezone
GENERIC_TIMEZONE=America/Los_Angeles

# Adjust resource limits if needed
FFMPEG_THREADS=4
FFMPEG_MAX_FILE_SIZE=500
```

---

## Verify Installation

### Check Docker Images

```bash
docker images | grep -E "ffmpeg-mcp|comfyui-mcp|utility-mcp"
```

### Check ComfyUI (Native)

```bash
# Start ComfyUI
cd ~/ComfyUI && source venv/bin/activate && python main.py &

# Wait a few seconds, then verify
curl -s http://localhost:8188/system_stats | jq .
```

### Test MCP in Standalone Mode

```bash
# Test FFmpeg MCP
docker run --rm -p 8002:8002 -e MODE=http ffmpeg-mcp:latest &
sleep 5
curl http://localhost:8002/health
docker stop $(docker ps -q --filter ancestor=ffmpeg-mcp:latest)

# Test ComfyUI MCP (ComfyUI must be running)
docker run --rm -p 8001:8001 -e MODE=http -e COMFYUI_URL=http://host.docker.internal:8188 comfyui-mcp:latest &
sleep 5
curl http://localhost:8001/health
docker stop $(docker ps -q --filter ancestor=comfyui-mcp:latest)
```

### Verify Workspace

```bash
ls -la ~/Documents/work/AI/ai-content-studio/workspace/
# Should show: input/, output/, temp/, jobs/, comfyui_output/

ls ~/Documents/work/AI/ai-content-studio/workspace/input/fixtures/
# Should show: test_video.mp4, test_audio.wav
```

---

## Next Steps

Once installation is complete:

1. **[Quick Start Guide](QUICK_START.md)** - Learn how to start and stop services
2. **[Usage with Claude](USAGE_CLAUDE.md)** - Use MCPs with Claude Desktop/Code
3. **[Usage with n8n](USAGE_N8N.md)** - Create automated workflows

---

## Troubleshooting Installation

### Docker build fails

```bash
# Clean Docker cache and rebuild
docker system prune -f
cd ~/Documents/work/AI/mcps/ffmpeg-mcp
./build.sh
```

### ComfyUI won't start

```bash
# Check Python version
python3 --version  # Should be 3.11+

# Reinstall dependencies
cd ~/ComfyUI
source venv/bin/activate
pip install -r requirements.txt --force-reinstall
```

### Port already in use

```bash
# Find what's using the port
lsof -i :8002

# Kill the process
kill -9 <PID>
```

See [Troubleshooting Guide](TROUBLESHOOTING.md) for more issues.

---

**Last Updated:** December 2025
