# Usage Guide: Claude Desktop & Claude Code

How to use AI Content Studio MCPs with Claude for interactive AI-assisted video creation.

---

## Table of Contents

1. [Overview](#overview)
2. [Claude Code Setup](#claude-code-setup)
3. [Claude Desktop Setup](#claude-desktop-setup)
4. [Example Workflows](#example-workflows)
5. [Tool Reference](#tool-reference)
6. [Best Practices](#best-practices)

---

## Overview

AI Content Studio provides **36 tools** across 3 MCPs that Claude can use:

| MCP | Tools | Purpose |
|-----|-------|---------|
| **FFmpeg MCP** | 15 | Video processing, text overlays, filters, GIFs |
| **ComfyUI MCP** | 12 | AI video generation, image animation |
| **Utility MCP** | 9 | Media analysis, format conversion, batch processing |

Claude can intelligently combine these tools to accomplish complex video creation tasks.

---

## Claude Code Setup

### Prerequisites

1. Claude Code installed (`npm install -g @anthropic/claude-code`)
2. MCP Docker images built (see [Initial Setup](INITIAL_SETUP.md))
3. ComfyUI running (for AI generation)

### Configuration

The `.mcp.json` file in `/Users/vikashruhil/Documents/work/AI/mcps/` configures all MCPs:

```json
{
  "mcpServers": {
    "ffmpeg-mcp": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-v", "/Users/vikashruhil/Documents/work/AI/ai-content-studio/workspace:/workspace",
        "-e", "MODE=stdio",
        "ffmpeg-mcp:latest"
      ]
    },
    "comfyui-mcp": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-v", "/Users/vikashruhil/Documents/work/AI/ai-content-studio/workspace:/workspace",
        "-e", "MODE=stdio",
        "-e", "COMFYUI_URL=http://host.docker.internal:8188",
        "comfyui-mcp:latest"
      ]
    },
    "utility-mcp": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-v", "/Users/vikashruhil/Documents/work/AI/ai-content-studio/workspace:/workspace",
        "-e", "MODE=stdio",
        "utility-mcp:latest"
      ]
    }
  }
}
```

### Starting Claude Code

```bash
# Navigate to mcps directory
cd ~/Documents/work/AI/mcps

# Start ComfyUI first (for AI generation)
cd ~/ComfyUI && source venv/bin/activate && python main.py &
cd ~/Documents/work/AI/mcps

# Start Claude Code
claude
```

### Verifying Tools

Ask Claude: "What video tools are available?"

Claude should list tools from all 3 MCPs.

---

## Claude Desktop Setup

### Option 1: Docker MCP Catalog

Add to `~/.docker/mcp/catalogs/custom.yaml`:

```yaml
registry:
  ffmpeg-mcp:
    image: ffmpeg-mcp:latest
    volumes:
      - ~/Documents/work/AI/ai-content-studio/workspace:/workspace
    environment:
      MODE: stdio

  comfyui-mcp:
    image: comfyui-mcp:latest
    volumes:
      - ~/Documents/work/AI/ai-content-studio/workspace:/workspace
    environment:
      MODE: stdio
      COMFYUI_URL: http://host.docker.internal:8188

  utility-mcp:
    image: utility-mcp:latest
    volumes:
      - ~/Documents/work/AI/ai-content-studio/workspace:/workspace
    environment:
      MODE: stdio
```

Restart Claude Desktop after adding.

### Option 2: Direct Configuration

Configure in Claude Desktop settings under MCP Servers.

---

## Example Workflows

### Example 1: Analyze and Add Text to Video

**Prompt:**
> "Analyze the video at /workspace/input/my_video.mp4 and add a title 'Welcome' at the top"

**What Claude does:**
1. Uses `analyze_media_file` to get video info
2. Uses `add_text_overlay` to add the title
3. Returns the output path

### Example 2: Create Social Media Content

**Prompt:**
> "Take my product video and optimize it for Instagram Reels with a 'Shop Now' button text"

**What Claude does:**
1. Uses `analyze_media_file` to check dimensions
2. Uses `optimize_for_platform` with `instagram_reels` preset
3. Uses `add_text_overlay` to add the CTA text
4. Returns the optimized video

### Example 3: Generate AI Video from Text

**Prompt:**
> "Generate a 3-second video of a sunset over the ocean"

**What Claude does:**
1. Uses `generate_video_from_text` with the prompt
2. Waits for generation to complete
3. Returns the generated video path

### Example 4: Create GIF from Video

**Prompt:**
> "Create a GIF from the first 5 seconds of my video with good quality"

**What Claude does:**
1. Uses `trim_video` to extract first 5 seconds
2. Uses `create_gif_from_video` with optimized settings
3. Returns the GIF path

### Example 5: Batch Process Multiple Files

**Prompt:**
> "Create thumbnails for all videos in /workspace/input/"

**What Claude does:**
1. Uses `batch_process_files` with `operation: thumbnail`
2. Processes all videos in the directory
3. Returns list of created thumbnails

### Example 6: Complex Pipeline

**Prompt:**
> "Generate a video of a cat playing, add some music from /workspace/input/music.mp3,
> add text 'Cute Cat!' at the bottom, and optimize for TikTok"

**What Claude does:**
1. `generate_video_from_text` - Create AI video
2. `add_audio_track` - Add background music
3. `add_text_overlay` - Add text caption
4. `optimize_for_platform` - Format for TikTok
5. Returns final video path

---

## Tool Reference

### FFmpeg MCP Tools

| Tool | Description | Example Use |
|------|-------------|-------------|
| `add_text_overlay` | Add text to video | Titles, captions, watermarks |
| `add_audio_track` | Mix audio into video | Background music, voiceover |
| `extract_audio` | Extract audio from video | Get music from video |
| `trim_video` | Cut video segments | Remove intro/outro |
| `concat_videos` | Join multiple videos | Combine clips |
| `apply_video_filter` | Apply visual filters | Blur, brightness, color |
| `create_gif_from_video` | Create optimized GIF | Social media reactions |
| `apply_transitions` | Add transitions | Fade, wipe, dissolve |
| `create_split_screen` | Grid layouts | Side-by-side comparison |
| `create_picture_in_picture` | PIP overlay | Reaction videos |
| `stabilize_video` | Stabilize shaky video | Handheld footage |
| `adjust_speed` | Speed up/slow down | Timelapse, slow-mo |
| `analyze_media` | Get media info | Check duration, resolution |

### ComfyUI MCP Tools

| Tool | Description | Example Use |
|------|-------------|-------------|
| `generate_video_from_text` | Text-to-video | AI video creation |
| `execute_custom_workflow` | Run custom workflow | Advanced generation |
| `check_generation_status` | Check AI status | Monitor progress |
| `animate_static_image` | Image to video | Animate photos |

### Utility MCP Tools

| Tool | Description | Example Use |
|------|-------------|-------------|
| `analyze_media_file` | Detailed media analysis | Get codec, bitrate info |
| `convert_format` | Format conversion | MP4 to WebM |
| `extract_frames` | Extract frames | Get thumbnails |
| `create_thumbnail` | Generate thumbnail | Video preview |
| `optimize_for_platform` | Platform presets | Instagram, TikTok |
| `list_comfyui_models` | List AI models | Check available models |
| `batch_process_files` | Batch operations | Process many files |

---

## Best Practices

### 1. Use Workspace Paths

Always use `/workspace/` paths:
```
/workspace/input/my_video.mp4      # Input files
/workspace/output/result.mp4        # Output files
/workspace/temp/                    # Temporary files
```

### 2. Provide Context

Give Claude context about your goal:

**Good:** "I need a 15-second Instagram Reel showcasing my product with text overlay and music"

**Bad:** "Add text to video"

### 3. Check Analysis First

For complex tasks, ask Claude to analyze the media first:
> "First analyze /workspace/input/video.mp4, then tell me the best approach to optimize it for YouTube"

### 4. Specify Quality Preferences

Be explicit about quality:
> "Create a high-quality GIF with smooth animation"
> "Optimize for fast loading while maintaining decent quality"

### 5. Use Platform Presets

Mention target platforms:
> "Format for Instagram Reels" (9:16, 1080x1920, max 90s)
> "Optimize for YouTube Shorts" (9:16, max 60s)
> "Prepare for Twitter" (16:9, max 2:20)

### 6. Handle Long Operations

AI generation can take time. Ask Claude to:
> "Generate a video and let me know when it's done"

### 7. Chain Operations Efficiently

Claude can chain multiple operations:
> "Trim to first 10 seconds, add fade transitions, then create a GIF"

---

## Troubleshooting

### "Tool not found"

Ensure MCPs are configured in `.mcp.json` and Docker images are built.

### "ComfyUI not available"

Start ComfyUI native before using ComfyUI MCP:
```bash
cd ~/ComfyUI && source venv/bin/activate && python main.py
```

### "File not found"

Ensure files are in `/workspace/input/` and path starts with `/workspace/`.

### "Generation timeout"

AI generation can take time. For long videos:
- Use shorter durations
- Lower resolution
- Check ComfyUI logs

---

## Next Steps

- **[Usage with n8n](USAGE_N8N.md)** - Automate workflows
- **[Troubleshooting](TROUBLESHOOTING.md)** - Common issues

---

**Last Updated:** December 2025
