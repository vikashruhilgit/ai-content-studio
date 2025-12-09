# Quick Start Guide

How to start, stop, and manage AI Content Studio after initial setup.

---

## Table of Contents

1. [Starting Services](#starting-services)
2. [Stopping Services](#stopping-services)
3. [Checking Status](#checking-status)
4. [Common Operations](#common-operations)

---

## Starting Services

### Option 1: Full Stack (Recommended)

Start all services including n8n for workflow automation:

```bash
# 1. Start ComfyUI (required for AI generation)
cd ~/ComfyUI && source venv/bin/activate && python main.py &

# 2. Wait for ComfyUI to start (about 10 seconds)
sleep 10

# 3. Verify ComfyUI is running
curl -s http://localhost:8188/system_stats | jq .

# 4. Start the Docker stack
cd ~/Documents/work/AI/ai-content-studio
docker-compose up -d

# 5. Verify all services
docker-compose ps
```

### Option 2: Individual MCPs

Start specific MCPs without the full stack:

**FFmpeg MCP only:**
```bash
docker run -d --name ffmpeg-mcp \
  -p 8002:8002 \
  -v ~/Documents/work/AI/ai-content-studio/workspace:/workspace \
  -e MODE=http \
  ffmpeg-mcp:latest
```

**ComfyUI MCP only:**
```bash
# First start ComfyUI native
cd ~/ComfyUI && source venv/bin/activate && python main.py &

# Then start the MCP
docker run -d --name comfyui-mcp \
  -p 8001:8001 \
  -v ~/Documents/work/AI/ai-content-studio/workspace:/workspace \
  -e MODE=http \
  -e COMFYUI_URL=http://host.docker.internal:8188 \
  comfyui-mcp:latest
```

**Utility MCP only:**
```bash
docker run -d --name utility-mcp \
  -p 8003:8003 \
  -v ~/Documents/work/AI/ai-content-studio/workspace:/workspace \
  -v ~/Documents/work/AI/ai-content-studio/templates:/workspace/templates \
  -e MODE=http \
  utility-mcp:latest
```

### Option 3: Claude Code Integration

For use with Claude Code (MCP stdio mode):

```bash
# Navigate to mcps directory (where .mcp.json is located)
cd ~/Documents/work/AI/mcps

# Start Claude Code
claude

# MCPs will be loaded automatically from .mcp.json
```

---

## Stopping Services

### Stop Full Stack

```bash
cd ~/Documents/work/AI/ai-content-studio

# Stop Docker containers (preserves data)
docker-compose down

# Stop ComfyUI
pkill -f "python main.py"
```

### Stop Individual Containers

```bash
# Stop and remove specific container
docker stop ffmpeg-mcp && docker rm ffmpeg-mcp
docker stop comfyui-mcp && docker rm comfyui-mcp
docker stop utility-mcp && docker rm utility-mcp
docker stop n8n-studio && docker rm n8n-studio
```

### Stop Everything and Clean Up

```bash
# Stop all containers
docker-compose down

# Remove volumes (WARNING: deletes n8n data)
docker-compose down -v

# Stop ComfyUI
pkill -f "python main.py"

# Clean up Docker resources
docker system prune -f
```

---

## Checking Status

### Quick Health Check

```bash
# Check all services in one command
echo "=== Service Status ===" && \
curl -s http://localhost:8001/health 2>/dev/null | jq -r '"ComfyUI MCP: " + .status' || echo "ComfyUI MCP: Not running" && \
curl -s http://localhost:8002/health 2>/dev/null | jq -r '"FFmpeg MCP: " + .status' || echo "FFmpeg MCP: Not running" && \
curl -s http://localhost:8003/health 2>/dev/null | jq -r '"Utility MCP: " + .status' || echo "Utility MCP: Not running" && \
curl -s http://localhost:8188/system_stats 2>/dev/null && echo "ComfyUI Native: Running" || echo "ComfyUI Native: Not running" && \
curl -s http://localhost:5678 2>/dev/null | head -1 && echo "n8n: Running" || echo "n8n: Not running"
```

### Docker Compose Status

```bash
cd ~/Documents/work/AI/ai-content-studio
docker-compose ps
```

Expected output when healthy:
```
NAME           STATUS         PORTS
comfyui-mcp    Up (healthy)   0.0.0.0:8001->8001/tcp
ffmpeg-mcp     Up (healthy)   0.0.0.0:8002->8002/tcp
utility-mcp    Up (healthy)   0.0.0.0:8003->8003/tcp
n8n-studio     Up             0.0.0.0:5678->5678/tcp
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f ffmpeg-mcp
docker-compose logs -f comfyui-mcp
docker-compose logs -f n8n

# Last 100 lines
docker-compose logs --tail 100 ffmpeg-mcp
```

### Check Docker Images

```bash
docker images | grep mcp
```

---

## Common Operations

### Restart a Service

```bash
# Via docker-compose
docker-compose restart ffmpeg-mcp
docker-compose restart comfyui-mcp

# Or stop and start
docker-compose stop ffmpeg-mcp
docker-compose start ffmpeg-mcp
```

### Rebuild After Code Changes

```bash
# Rebuild specific MCP
cd ~/Documents/work/AI/mcps/ffmpeg-mcp
./build.sh

# Restart the service
cd ~/Documents/work/AI/ai-content-studio
docker-compose up -d --force-recreate ffmpeg-mcp
```

### View Resource Usage

```bash
# Container resource usage
docker stats --no-stream

# Disk usage
docker system df
df -h ~/Documents/work/AI/ai-content-studio/workspace
```

### Clean Up Workspace

```bash
# Remove temporary files
rm -rf ~/Documents/work/AI/ai-content-studio/workspace/temp/*

# Remove old outputs (be careful!)
# rm -rf ~/Documents/work/AI/ai-content-studio/workspace/output/*
```

### Access n8n UI

1. Open browser: http://localhost:5678
2. Login with credentials from `.env`:
   - Default user: `admin`
   - Default password: `changeme` (change this!)

### Run Smoke Test

```bash
# Via n8n UI
# 1. Open http://localhost:5678
# 2. Import workflow from: n8n/workflows/smoke_test.json
# 3. Click "Execute Workflow"

# Or via API
curl -X POST http://localhost:8002/api/v1/tools/analyze \
  -H "Content-Type: application/json" \
  -d '{"input_file": "/workspace/input/fixtures/test_video.mp4"}'
```

---

## Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| FFmpeg MCP | http://localhost:8002 | Video processing API |
| ComfyUI MCP | http://localhost:8001 | AI generation API |
| Utility MCP | http://localhost:8003 | Utility tools API |
| n8n | http://localhost:5678 | Workflow automation UI |
| ComfyUI | http://localhost:8188 | AI generation UI |

---

## Quick Reference Commands

```bash
# Start everything
cd ~/ComfyUI && source venv/bin/activate && python main.py &
cd ~/Documents/work/AI/ai-content-studio && docker-compose up -d

# Stop everything
docker-compose down && pkill -f "python main.py"

# Check status
docker-compose ps && curl -s http://localhost:8002/health | jq .

# View logs
docker-compose logs -f

# Restart service
docker-compose restart ffmpeg-mcp
```

---

## Next Steps

- **[Usage with Claude](USAGE_CLAUDE.md)** - Use MCPs interactively with Claude
- **[Usage with n8n](USAGE_N8N.md)** - Create automated workflows
- **[Troubleshooting](TROUBLESHOOTING.md)** - Common issues and solutions

---

**Last Updated:** December 2025
