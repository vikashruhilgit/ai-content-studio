# Usage Guide: n8n Workflow Automation

How to use AI Content Studio MCPs with n8n for automated video processing pipelines.

---

## Table of Contents

1. [Overview](#overview)
2. [n8n Setup](#n8n-setup)
3. [HTTP API Reference](#http-api-reference)
4. [Example Workflows](#example-workflows)
5. [Building Custom Workflows](#building-custom-workflows)
6. [Webhook Integration](#webhook-integration)
7. [Best Practices](#best-practices)

---

## Overview

n8n provides visual workflow automation that can orchestrate all 3 MCPs:

| MCP | HTTP Port | API Base | Purpose |
|-----|-----------|----------|---------|
| **FFmpeg MCP** | 8002 | `http://ffmpeg-mcp:8002/api/v1` | Video processing |
| **ComfyUI MCP** | 8001 | `http://comfyui-mcp:8001/api/v1` | AI generation |
| **Utility MCP** | 8003 | `http://utility-mcp:8003/api/v1` | Media utilities |

**Key Benefits:**
- Visual workflow builder
- Scheduled automation
- Webhook triggers
- Error handling & retries
- Parallel processing

---

## n8n Setup

### Accessing n8n

1. Start the stack: `docker-compose up -d`
2. Open browser: http://localhost:5678
3. Login with credentials from `.env`:
   - Default user: `admin`
   - Default password: `changeme` (change this!)

### First-Time Setup

1. Create a new workflow
2. Add an HTTP Request node
3. Test connectivity to MCPs:

**Test FFmpeg MCP:**
```
Method: GET
URL: http://ffmpeg-mcp:8002/health
```

**Test Utility MCP:**
```
Method: GET
URL: http://utility-mcp:8003/health
```

---

## HTTP API Reference

### FFmpeg MCP Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/tools/add_text_overlay` | POST | Add text to video |
| `/api/v1/tools/add_audio_track` | POST | Mix audio into video |
| `/api/v1/tools/extract_audio` | POST | Extract audio from video |
| `/api/v1/tools/trim_video` | POST | Cut video segments |
| `/api/v1/tools/concat_videos` | POST | Join multiple videos |
| `/api/v1/tools/apply_video_filter` | POST | Apply filters |
| `/api/v1/tools/create_gif_from_video` | POST | Create GIF |
| `/api/v1/tools/apply_transitions` | POST | Add transitions |
| `/api/v1/tools/create_split_screen` | POST | Grid layouts |
| `/api/v1/tools/create_picture_in_picture` | POST | PIP overlay |
| `/api/v1/tools/stabilize_video` | POST | Stabilize video |
| `/api/v1/tools/adjust_speed` | POST | Speed control |
| `/api/v1/tools/analyze` | POST | Get media info |

### ComfyUI MCP Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/tools/generate_video_from_text` | POST | Text-to-video |
| `/api/v1/tools/execute_custom_workflow` | POST | Run workflow |
| `/api/v1/tools/check_generation_status` | GET | Check status |

### Utility MCP Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/tools/analyze_media_file` | POST | Detailed analysis |
| `/api/v1/tools/convert_format` | POST | Format conversion |
| `/api/v1/tools/extract_frames` | POST | Frame extraction |
| `/api/v1/tools/create_thumbnail` | POST | Generate thumbnail |
| `/api/v1/tools/optimize_for_platform` | POST | Platform presets |
| `/api/v1/tools/batch_process_files` | POST | Batch operations |

---

## Example Workflows

### Example 1: Smoke Test Workflow

Import `n8n/workflows/smoke_test.json` to verify MCP connectivity.

**Workflow:**
1. Manual Trigger
2. HTTP Request to FFmpeg MCP health
3. HTTP Request to analyze test video
4. Display results

### Example 2: Video to GIF Pipeline

**Workflow Nodes:**

```
[Manual Trigger] → [Analyze Video] → [Trim Video] → [Create GIF] → [Respond]
```

**Node 1: Analyze Video (HTTP Request)**
```json
{
  "method": "POST",
  "url": "http://ffmpeg-mcp:8002/api/v1/tools/analyze",
  "body": {
    "input_file": "/workspace/input/video.mp4"
  }
}
```

**Node 2: Trim Video (HTTP Request)**
```json
{
  "method": "POST",
  "url": "http://ffmpeg-mcp:8002/api/v1/tools/trim_video",
  "body": {
    "input_file": "/workspace/input/video.mp4",
    "start_time": "00:00:00",
    "end_time": "00:00:05",
    "output_file": "/workspace/temp/trimmed.mp4"
  }
}
```

**Node 3: Create GIF (HTTP Request)**
```json
{
  "method": "POST",
  "url": "http://ffmpeg-mcp:8002/api/v1/tools/create_gif_from_video",
  "body": {
    "input_file": "/workspace/temp/trimmed.mp4",
    "output_file": "/workspace/output/result.gif",
    "fps": 15,
    "width": 480
  }
}
```

### Example 3: Social Media Optimizer

**Workflow:**
```
[Webhook] → [Analyze] → [Switch by Platform] → [Optimize] → [Add Text] → [Webhook Response]
```

**Switch Node Conditions:**
- Instagram Reels: `{{ $json.platform === 'instagram' }}`
- TikTok: `{{ $json.platform === 'tiktok' }}`
- YouTube Shorts: `{{ $json.platform === 'youtube' }}`

**Instagram Branch (HTTP Request):**
```json
{
  "method": "POST",
  "url": "http://utility-mcp:8003/api/v1/tools/optimize_for_platform",
  "body": {
    "input_file": "{{ $json.input_file }}",
    "platform": "instagram_reels",
    "output_file": "/workspace/output/instagram_{{ $now.format('yyyyMMdd_HHmmss') }}.mp4"
  }
}
```

### Example 4: Batch Thumbnail Generator

**Workflow:**
```
[Schedule Trigger] → [List Files] → [Loop] → [Create Thumbnail] → [Move to Output]
```

**Schedule:** Every hour

**Batch Process Node:**
```json
{
  "method": "POST",
  "url": "http://utility-mcp:8003/api/v1/tools/batch_process_files",
  "body": {
    "input_directory": "/workspace/input",
    "operation": "thumbnail",
    "output_directory": "/workspace/output/thumbnails"
  }
}
```

### Example 5: AI Video Generation Pipeline

**Workflow:**
```
[Webhook] → [Generate Video] → [Wait] → [Check Status] → [Add Text] → [Optimize] → [Respond]
```

**Generate Video Node:**
```json
{
  "method": "POST",
  "url": "http://comfyui-mcp:8001/api/v1/tools/generate_video_from_text",
  "body": {
    "prompt": "{{ $json.prompt }}",
    "negative_prompt": "blurry, low quality",
    "num_frames": 16,
    "fps": 8
  }
}
```

**Wait Node:** 30 seconds (adjust based on generation time)

**Check Status Node:**
```json
{
  "method": "GET",
  "url": "http://comfyui-mcp:8001/api/v1/tools/check_generation_status"
}
```

---

## Building Custom Workflows

### HTTP Request Node Configuration

**Basic Setup:**
1. Add HTTP Request node
2. Set Method: POST
3. Set URL: `http://[mcp-name]:8002/api/v1/tools/[tool-name]`
4. Body Content Type: JSON
5. Add body parameters

**Using Previous Node Data:**
```json
{
  "input_file": "{{ $json.output_file }}",
  "output_file": "/workspace/output/final_{{ $now.format('yyyyMMdd') }}.mp4"
}
```

### Error Handling

**Add Error Trigger:**
1. Right-click workflow → Settings
2. Enable "Error Workflow"
3. Create error handling workflow

**Retry Configuration:**
1. Select HTTP Request node → Settings
2. Enable "Retry on Fail"
3. Set retry count: 3
4. Set wait between retries: 1000ms

### Conditional Logic

**IF Node Example:**
```javascript
// Check if video is longer than 60 seconds
{{ $json.duration > 60 }}
```

**Switch Node Cases:**
```javascript
// Route by file extension
{{ $json.filename.split('.').pop() }}
// Cases: mp4, mov, avi, webm
```

### Parallel Processing

Use **Split In Batches** node for processing multiple files:

1. Add "Split In Batches" node after file list
2. Set batch size: 3 (process 3 files at once)
3. Connect to processing nodes
4. Add "Merge" node to collect results

---

## Webhook Integration

### Creating a Webhook Endpoint

1. Add "Webhook" node as trigger
2. Set HTTP Method: POST
3. Copy the webhook URL
4. Test with curl:

```bash
curl -X POST http://localhost:5678/webhook/your-webhook-id \
  -H "Content-Type: application/json" \
  -d '{"input_file": "/workspace/input/video.mp4", "platform": "instagram"}'
```

### Webhook Response

Add "Respond to Webhook" node at the end:

```json
{
  "success": true,
  "output_file": "{{ $json.output_file }}",
  "message": "Video processed successfully"
}
```

### External Integration Examples

**From a Web App:**
```javascript
const response = await fetch('http://localhost:5678/webhook/video-process', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    input_file: '/workspace/input/upload.mp4',
    platform: 'tiktok',
    text_overlay: 'My Video Title'
  })
});
const result = await response.json();
console.log('Output:', result.output_file);
```

**From Python:**
```python
import requests

response = requests.post(
    'http://localhost:5678/webhook/video-process',
    json={
        'input_file': '/workspace/input/upload.mp4',
        'platform': 'instagram',
        'text_overlay': 'Check this out!'
    }
)
print(response.json())
```

---

## Best Practices

### 1. Use Workspace Paths

Always use `/workspace/` paths in n8n workflows:
```
/workspace/input/      # Source files
/workspace/output/     # Final outputs
/workspace/temp/       # Intermediate files
```

### 2. Add Health Checks

Start workflows with health check:
```json
{
  "method": "GET",
  "url": "http://ffmpeg-mcp:8002/health"
}
```

### 3. Use Variables for Paths

Set workflow variables:
```
WORKSPACE=/workspace
INPUT_DIR={{ $vars.WORKSPACE }}/input
OUTPUT_DIR={{ $vars.WORKSPACE }}/output
```

### 4. Implement Error Handling

Always add:
- Error Trigger workflow
- Retry logic on HTTP nodes
- Timeout settings (default: 300000ms)

### 5. Log Important Steps

Add "Set" nodes to log progress:
```json
{
  "step": "Trimming complete",
  "file": "{{ $json.output_file }}",
  "timestamp": "{{ $now.toISO() }}"
}
```

### 6. Clean Up Temp Files

Add cleanup step at workflow end:
```json
{
  "method": "DELETE",
  "url": "http://utility-mcp:8003/api/v1/cleanup",
  "body": {
    "directory": "/workspace/temp",
    "older_than_hours": 24
  }
}
```

### 7. Use Meaningful Output Names

Include timestamps in output files:
```
/workspace/output/instagram_{{ $now.format('yyyyMMdd_HHmmss') }}.mp4
```

---

## Workflow Templates

Pre-built workflow templates are available in `n8n/workflows/`:

| Template | Description |
|----------|-------------|
| `smoke_test.json` | Verify MCP connectivity |
| `video_to_gif.json` | Convert video to GIF |
| `social_optimizer.json` | Multi-platform optimization |
| `batch_thumbnails.json` | Batch thumbnail generation |
| `ai_video_pipeline.json` | AI video generation workflow |

### Importing Templates

1. Open n8n (http://localhost:5678)
2. Click "..." menu → Import from File
3. Select template JSON from `n8n/workflows/`
4. Activate workflow

---

## Troubleshooting n8n

### "Connection refused" Errors

Use container names, not localhost:
- Correct: `http://ffmpeg-mcp:8002`
- Wrong: `http://localhost:8002`

### Workflow Timeout

Increase timeout in HTTP Request node:
- Settings → Timeout → 300000 (5 minutes)

### Large File Processing

For large files:
1. Increase Docker memory limits
2. Use batch processing
3. Add progress polling

### Webhook Not Responding

1. Check workflow is activated
2. Verify webhook URL is correct
3. Check n8n logs: `docker logs n8n-studio`

---

## Next Steps

- **[Usage with Claude](USAGE_CLAUDE.md)** - Interactive AI assistance
- **[Troubleshooting](TROUBLESHOOTING.md)** - Common issues
- **[Quick Start](QUICK_START.md)** - Start/stop services

---

**Last Updated:** December 2025
