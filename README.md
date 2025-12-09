# AI Content Studio

Local AI video generation and processing system combining ComfyUI, FFmpeg, and n8n workflow automation.

**36 tools** across 3 MCP servers for video processing, AI generation, and media utilities.

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        AI Content Studio                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐            │
│  │ ComfyUI MCP │   │ FFmpeg MCP  │   │ Utility MCP │            │
│  │  Port 8001  │   │  Port 8002  │   │  Port 8003  │            │
│  │  12 tools   │   │  15 tools   │   │   9 tools   │            │
│  └──────┬──────┘   └──────┬──────┘   └──────┬──────┘            │
│         │                 │                  │                    │
│         └────────────┬────┴──────────────────┘                   │
│                      │                                            │
│              ┌───────▼────────┐                                  │
│              │      n8n       │  ← Workflow automation           │
│              │   Port 5678    │                                  │
│              └───────┬────────┘                                  │
│                      │                                            │
│              ┌───────▼────────┐                                  │
│              │   /workspace   │  ← Shared file system            │
│              │  input/output  │                                  │
│              └────────────────┘                                  │
└─────────────────────────────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                    ComfyUI (Native)                              │
│                    localhost:8188                                │
│                    GPU-accelerated AI generation                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Features

### FFmpeg MCP (15 tools)
Video processing, text overlays, filters, GIFs, transitions, split-screen, and more.

### ComfyUI MCP (12 tools)
AI video generation with AnimateDiff, text-to-video, image animation.

### Utility MCP (9 tools)
Media analysis, format conversion, thumbnails, batch processing, platform optimization.

### n8n Integration
Visual workflow builder with webhooks, scheduling, and automated pipelines.

---

## Quick Start

### Prerequisites

- Docker Desktop 4.0+
- macOS 13+ / Linux / Windows WSL2
- For AI generation: Apple Silicon Mac or NVIDIA GPU

### 1. Clone Repositories

```bash
# Clone AI Content Studio
git clone https://github.com/vikashruhilgit/ai-content-studio.git
cd ai-content-studio

# Clone MCPs (in parent directory)
cd ..
git clone https://github.com/vikashruhilgit/mcps.git
```

### 2. Build Docker Images

```bash
cd mcps

# Build all MCPs
cd ffmpeg-mcp && chmod +x build.sh && ./build.sh && cd ..
cd comfyui-mcp && chmod +x build.sh && ./build.sh && cd ..
cd utility-mcp && chmod +x build.sh && ./build.sh && cd ..

# Verify images
docker images | grep mcp
```

### 3. Start Services

```bash
cd ../ai-content-studio

# Copy environment file
cp .env.example .env

# Start the stack
docker-compose up -d

# Verify services
docker-compose ps
```

### 4. Verify Health

```bash
curl http://localhost:8002/health  # FFmpeg MCP
curl http://localhost:8003/health  # Utility MCP
```

**For AI generation**, start ComfyUI first:
```bash
cd ~/ComfyUI && source venv/bin/activate && python main.py &
curl http://localhost:8188/system_stats  # Verify ComfyUI
curl http://localhost:8001/health        # ComfyUI MCP
```

---

## Usage

### With Claude Code

```bash
cd ~/Documents/work/AI/mcps
claude

# Example prompts:
# "Add text 'Subscribe!' to my video at /workspace/input/video.mp4"
# "Generate a 3-second video of a sunset over the ocean"
# "Create a GIF from the first 5 seconds of my video"
# "Optimize my video for Instagram Reels"
```

### With n8n

1. Open http://localhost:5678
2. Login (credentials in `.env`)
3. Create workflow with HTTP Request nodes
4. Use container URLs: `http://ffmpeg-mcp:8002/api/v1/tools/...`

### With HTTP API

```bash
# Analyze video
curl -X POST http://localhost:8002/api/v1/tools/analyze \
  -H "Content-Type: application/json" \
  -d '{"input_file": "/workspace/input/video.mp4"}'

# Add text overlay
curl -X POST http://localhost:8002/api/v1/tools/add_text_overlay \
  -H "Content-Type: application/json" \
  -d '{
    "input_video": "/workspace/input/video.mp4",
    "text_content": "Hello World",
    "position": "center"
  }'
```

---

## Workspace Structure

```
workspace/
├── input/              # Upload source files here
│   └── fixtures/       # Test files (test_video.mp4)
├── output/             # Processed/generated content
├── comfyui_output/     # Raw AI generations
├── temp/               # Temporary files (auto-cleanup)
└── jobs/               # Job tracking data
```

---

## Service URLs

| Service | Port | Health Check |
|---------|------|--------------|
| FFmpeg MCP | 8002 | `http://localhost:8002/health` |
| ComfyUI MCP | 8001 | `http://localhost:8001/health` |
| Utility MCP | 8003 | `http://localhost:8003/health` |
| n8n | 5678 | `http://localhost:5678` |
| ComfyUI (Native) | 8188 | `http://localhost:8188/system_stats` |

---

## Documentation

| Document | Description |
|----------|-------------|
| **[Application Status](APPLICATION_STATUS.md)** | Component status, tool inventory, development phases |
| **[Initial Setup](docs/INITIAL_SETUP.md)** | System requirements, prerequisites, full installation guide |
| **[Quick Start](docs/QUICK_START.md)** | Start/stop commands, health checks, common operations |
| **[Usage with Claude](docs/USAGE_CLAUDE.md)** | Claude Desktop & Claude Code integration, example prompts |
| **[Usage with n8n](docs/USAGE_N8N.md)** | Workflow automation, webhook integration, example pipelines |
| **[Troubleshooting](docs/TROUBLESHOOTING.md)** | Common issues, diagnostics, resource management |

---

## Related Repositories

- **MCPs**: https://github.com/vikashruhilgit/mcps
  - FFmpeg MCP - Video processing tools
  - ComfyUI MCP - AI generation tools
  - Utility MCP - Media utility tools

---

## Environment Variables

Key configuration options (see `.env.example` for full list):

| Variable | Default | Description |
|----------|---------|-------------|
| `N8N_USER` | admin | n8n login username |
| `N8N_PASSWORD` | changeme | n8n login password (change this!) |
| `COMFYUI_URL` | http://host.docker.internal:8188 | ComfyUI backend URL |
| `FFMPEG_THREADS` | 4 | FFmpeg parallel threads |
| `LOG_LEVEL` | INFO | Logging verbosity |

---

## Stop Services

```bash
# Stop Docker stack
docker-compose down

# Stop ComfyUI (if running)
pkill -f "python main.py"

# Full cleanup (removes volumes)
docker-compose down -v
```

---

## License

MIT

---

**Last Updated:** December 2025
