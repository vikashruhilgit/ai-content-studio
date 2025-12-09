# Troubleshooting Guide

Common issues and solutions for AI Content Studio.

---

## Table of Contents

1. [Quick Diagnostics](#quick-diagnostics)
2. [Docker Issues](#docker-issues)
3. [MCP Issues](#mcp-issues)
4. [ComfyUI Issues](#comfyui-issues)
5. [n8n Issues](#n8n-issues)
6. [File & Path Issues](#file--path-issues)
7. [Performance Issues](#performance-issues)
8. [Resource Management](#resource-management)

---

## Quick Diagnostics

### Health Check Script

Run this to diagnose all services:

```bash
#!/bin/bash
echo "=== AI Content Studio Diagnostics ==="
echo ""

# Check Docker
echo "Docker Status:"
docker info > /dev/null 2>&1 && echo "  Docker: Running" || echo "  Docker: NOT RUNNING"
echo ""

# Check Images
echo "Docker Images:"
docker images | grep -E "ffmpeg-mcp|comfyui-mcp|utility-mcp" | awk '{print "  " $1 ": " $2}'
echo ""

# Check Containers
echo "Running Containers:"
docker ps --format "  {{.Names}}: {{.Status}}" | grep -E "mcp|n8n"
echo ""

# Check Services (HTTP mode)
echo "Service Health:"
curl -s http://localhost:8001/health 2>/dev/null | jq -r '"  ComfyUI MCP: " + .status' || echo "  ComfyUI MCP: Not responding"
curl -s http://localhost:8002/health 2>/dev/null | jq -r '"  FFmpeg MCP: " + .status' || echo "  FFmpeg MCP: Not responding"
curl -s http://localhost:8003/health 2>/dev/null | jq -r '"  Utility MCP: " + .status' || echo "  Utility MCP: Not responding"
curl -s http://localhost:8188/system_stats 2>/dev/null && echo "  ComfyUI Native: Running" || echo "  ComfyUI Native: Not responding"
curl -s http://localhost:5678 2>/dev/null > /dev/null && echo "  n8n: Running" || echo "  n8n: Not responding"
echo ""

# Check Workspace
echo "Workspace:"
ls -la ~/Documents/work/AI/ai-content-studio/workspace/ 2>/dev/null | head -5 || echo "  Workspace not found"
echo ""

# Check Disk Space
echo "Disk Space:"
df -h ~/Documents/work/AI/ai-content-studio/workspace 2>/dev/null | tail -1 | awk '{print "  Available: " $4}'
```

---

## Docker Issues

### Docker Not Running

**Symptom:** `Cannot connect to Docker daemon`

**Solution:**
```bash
# macOS
open -a Docker

# Linux
sudo systemctl start docker

# Verify
docker info
```

### Docker Image Not Found

**Symptom:** `Unable to find image 'ffmpeg-mcp:latest'`

**Solution:**
```bash
# Rebuild images
cd ~/Documents/work/AI/mcps/ffmpeg-mcp && ./build.sh
cd ~/Documents/work/AI/mcps/comfyui-mcp && ./build.sh
cd ~/Documents/work/AI/mcps/utility-mcp && ./build.sh

# Verify
docker images | grep mcp
```

### Port Already in Use

**Symptom:** `Bind for 0.0.0.0:8002 failed: port is already allocated`

**Solution:**
```bash
# Find what's using the port
lsof -i :8002

# Kill the process
kill -9 <PID>

# Or stop all containers
docker stop $(docker ps -q)

# Restart
docker-compose up -d
```

### Out of Disk Space

**Symptom:** `no space left on device`

**Solution:**
```bash
# Check disk usage
df -h

# Clean Docker
docker system prune -a -f

# Clean workspace temp files
rm -rf ~/Documents/work/AI/ai-content-studio/workspace/temp/*

# Remove old outputs (be careful!)
# rm -rf ~/Documents/work/AI/ai-content-studio/workspace/output/*
```

### Container Keeps Restarting

**Symptom:** Container status shows `Restarting`

**Solution:**
```bash
# Check logs
docker logs ffmpeg-mcp --tail 100

# Common causes:
# 1. Missing environment variables - check .env
# 2. Port conflict - change ports in docker-compose.yml
# 3. Memory limit - increase Docker memory allocation
```

---

## MCP Issues

### MCP Not Appearing in Claude Desktop

**Symptom:** Tools don't show in Claude Desktop

**Solution:**
1. Verify Docker catalog configuration:
```bash
cat ~/.docker/mcp/catalogs/custom.yaml
```

2. Check secrets are set:
```bash
docker mcp secret ls
```

3. Restart Claude Desktop completely

### MCP Not Working in Claude Code

**Symptom:** `No MCP servers configured`

**Solution:**
1. Verify `.mcp.json` exists:
```bash
cat ~/Documents/work/AI/mcps/.mcp.json
```

2. Navigate to correct directory:
```bash
cd ~/Documents/work/AI/mcps
claude
```

3. Check Docker images exist:
```bash
docker images | grep mcp
```

### MCP Health Shows "degraded"

**Symptom:** Health endpoint returns `"status": "degraded"`

**Cause:** ComfyUI MCP can't connect to native ComfyUI

**Solution:**
```bash
# Start ComfyUI native
cd ~/ComfyUI
source venv/bin/activate
python main.py

# Verify
curl http://localhost:8188/system_stats
```

### Tool Returns Error

**Symptom:** Tool call fails with error message

**Debug Steps:**
```bash
# Check container logs
docker logs ffmpeg-mcp --tail 50

# Test with curl
curl -X POST http://localhost:8002/api/v1/tools/analyze \
  -H "Content-Type: application/json" \
  -d '{"input_file": "/workspace/input/test.mp4"}'

# Check file exists in container
docker exec ffmpeg-mcp ls -la /workspace/input/
```

---

## ComfyUI Issues

### ComfyUI Won't Start

**Symptom:** `python main.py` fails

**Solution:**
```bash
cd ~/ComfyUI

# Check Python version
python3 --version  # Should be 3.11+

# Activate venv
source venv/bin/activate

# Reinstall dependencies
pip install -r requirements.txt --force-reinstall

# Try starting
python main.py
```

### Missing Models

**Symptom:** `FileNotFoundError: models/checkpoints/...`

**Solution:**
```bash
# Check model directories
ls ~/ComfyUI/models/checkpoints/
ls ~/ComfyUI/models/animatediff_models/

# If missing, download required models (see INITIAL_SETUP.md)
```

### Generation Hangs

**Symptom:** Video generation never completes

**Possible Causes:**
1. **Insufficient VRAM:** Reduce `num_frames` or resolution
2. **ComfyUI crashed:** Check ComfyUI terminal for errors
3. **Network timeout:** Increase `COMFYUI_TIMEOUT` in `.env`

**Solution:**
```bash
# Check ComfyUI status
curl http://localhost:8188/queue

# Cancel stuck jobs
curl -X POST http://localhost:8188/interrupt

# Restart ComfyUI
pkill -f "python main.py"
cd ~/ComfyUI && source venv/bin/activate && python main.py
```

### Metal/GPU Errors (macOS)

**Symptom:** `RuntimeError: MPS backend out of memory`

**Solution:**
```bash
# Clear Metal memory
sudo purge

# Reduce batch size in workflow
# Or reduce num_frames parameter

# Restart ComfyUI
```

---

## n8n Issues

### Can't Access n8n UI

**Symptom:** http://localhost:5678 doesn't load

**Solution:**
```bash
# Check container is running
docker ps | grep n8n

# Start if not running
cd ~/Documents/work/AI/ai-content-studio
docker-compose up -d n8n

# Check logs
docker logs n8n-studio --tail 50
```

### Forgot n8n Password

**Solution:**
```bash
# Stop n8n
docker-compose stop n8n

# Reset password via environment
# Edit .env and set:
N8N_PASSWORD=new_password

# Restart with fresh DB (WARNING: loses workflows!)
docker-compose down
rm -rf ~/Documents/work/AI/ai-content-studio/n8n/data/*
docker-compose up -d
```

### Workflow Can't Connect to MCP

**Symptom:** `Connection refused` in HTTP Request node

**Cause:** Using wrong hostname

**Solution:**
Use container names, not localhost:
```
Wrong:  http://localhost:8002
Right:  http://ffmpeg-mcp:8002
```

### Webhook Not Triggering

**Symptom:** External requests don't trigger workflow

**Checklist:**
1. Workflow is **activated** (toggle in top right)
2. Webhook URL is correct
3. HTTP method matches (POST/GET)
4. n8n is accessible from external network

```bash
# Test webhook locally
curl -X POST http://localhost:5678/webhook/your-webhook-id \
  -H "Content-Type: application/json" \
  -d '{"test": true}'
```

---

## File & Path Issues

### File Not Found

**Symptom:** `Input file not found: /workspace/input/video.mp4`

**Checklist:**
1. File path starts with `/workspace/`
2. File exists in correct directory
3. File name matches exactly (case-sensitive)

```bash
# Check file exists on host
ls ~/Documents/work/AI/ai-content-studio/workspace/input/

# Check file is accessible in container
docker exec ffmpeg-mcp ls -la /workspace/input/
```

### Permission Denied

**Symptom:** `Permission denied` when writing output

**Solution:**
```bash
# Fix workspace permissions
chmod -R 755 ~/Documents/work/AI/ai-content-studio/workspace

# Check owner
ls -la ~/Documents/work/AI/ai-content-studio/workspace

# If needed, fix ownership
sudo chown -R $(whoami) ~/Documents/work/AI/ai-content-studio/workspace
```

### Output File Not Created

**Symptom:** Tool reports success but file doesn't exist

**Debug:**
```bash
# Check container's output directory
docker exec ffmpeg-mcp ls -la /workspace/output/

# Check host's output directory
ls -la ~/Documents/work/AI/ai-content-studio/workspace/output/

# Verify volume mount
docker inspect ffmpeg-mcp | grep -A 10 Mounts
```

---

## Performance Issues

### Slow Video Processing

**Possible Causes:**
1. Large input file
2. High resolution output
3. Insufficient CPU/RAM

**Solutions:**
```bash
# Check resource usage
docker stats --no-stream

# Increase threads in .env
FFMPEG_THREADS=8

# Reduce output quality/resolution
# Use platform presets which auto-optimize
```

### AI Generation Very Slow

**Factors:**
- Number of frames
- Resolution
- Model complexity
- Available VRAM

**Optimization:**
```bash
# Reduce frames (16 frames = ~2 seconds)
# Reduce resolution (512x512 instead of 768x768)
# Use smaller models if available
```

### High Memory Usage

**Monitor:**
```bash
# Docker memory
docker stats

# System memory
htop  # or Activity Monitor on macOS
```

**Solutions:**
1. Limit container memory in `docker-compose.yml`:
```yaml
services:
  ffmpeg-mcp:
    mem_limit: 2g
```

2. Process files sequentially instead of in parallel

---

## Resource Management

### Workspace Cleanup

**Automated Cleanup:**
```bash
# Remove temp files older than 24 hours
find ~/Documents/work/AI/ai-content-studio/workspace/temp -mtime +1 -delete

# Remove old job files
find ~/Documents/work/AI/ai-content-studio/workspace/jobs -mtime +7 -delete
```

**Manual Cleanup:**
```bash
# Clear temp directory
rm -rf ~/Documents/work/AI/ai-content-studio/workspace/temp/*

# Clear ComfyUI output
rm -rf ~/Documents/work/AI/ai-content-studio/workspace/comfyui_output/*

# Clear old outputs (review first!)
ls -lt ~/Documents/work/AI/ai-content-studio/workspace/output/
# rm specific old files
```

### Docker Cleanup

```bash
# Remove stopped containers
docker container prune -f

# Remove unused images
docker image prune -f

# Remove unused volumes
docker volume prune -f

# Full cleanup (WARNING: removes everything unused)
docker system prune -a -f

# Check disk usage after cleanup
docker system df
```

### Log Management

```bash
# View logs with limits
docker logs ffmpeg-mcp --tail 100

# Clear container logs (requires root on Linux)
sudo truncate -s 0 /var/lib/docker/containers/*/*-json.log

# Or restart container to clear logs
docker-compose restart ffmpeg-mcp
```

### Monitoring Resource Usage

**Create monitoring script:**
```bash
#!/bin/bash
# save as monitor.sh

while true; do
  clear
  echo "=== AI Content Studio Monitor ==="
  echo ""
  echo "Docker Containers:"
  docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
  echo ""
  echo "Workspace Disk Usage:"
  du -sh ~/Documents/work/AI/ai-content-studio/workspace/*
  echo ""
  echo "Press Ctrl+C to exit"
  sleep 5
done
```

---

## Getting Help

### Collect Debug Information

Before reporting issues, gather:

```bash
# System info
uname -a
docker version
python3 --version

# Container status
docker-compose ps
docker logs ffmpeg-mcp --tail 50
docker logs comfyui-mcp --tail 50

# Disk space
df -h

# Recent errors
docker-compose logs --tail 100 | grep -i error
```

### Log Locations

| Component | Log Location |
|-----------|--------------|
| FFmpeg MCP | `docker logs ffmpeg-mcp` |
| ComfyUI MCP | `docker logs comfyui-mcp` |
| Utility MCP | `docker logs utility-mcp` |
| n8n | `docker logs n8n-studio` |
| ComfyUI Native | Terminal where `python main.py` runs |

### Report Issues

**GitHub Repositories:**
- AI Content Studio: https://github.com/vikashruhilgit/ai-content-studio
- MCPs: https://github.com/vikashruhilgit/mcps

When reporting:
1. Describe what you were trying to do
2. Include error messages
3. List steps to reproduce
4. Include debug information from above

---

## Next Steps

- **[Quick Start](QUICK_START.md)** - Start/stop services
- **[Initial Setup](INITIAL_SETUP.md)** - Re-run setup
- **[Usage with Claude](USAGE_CLAUDE.md)** - Interactive usage
- **[Usage with n8n](USAGE_N8N.md)** - Workflow automation

---

**Last Updated:** December 2025
