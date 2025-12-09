#!/bin/bash
# Generate test fixtures for AI Content Studio
# Requires: FFmpeg (brew install ffmpeg)

set -e

FIXTURES_DIR="$(dirname "$0")/../workspace/input/fixtures"
mkdir -p "$FIXTURES_DIR"

echo "Generating test fixtures..."

# Check if FFmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: FFmpeg is required. Install with: brew install ffmpeg"
    exit 1
fi

# Generate 2-second test video (720p, solid color with text)
echo "Creating test_video.mp4 (2 seconds, 720p)..."
ffmpeg -y -f lavfi -i "color=c=blue:s=1280x720:d=2" \
    -vf "drawtext=text='TEST VIDEO':fontsize=72:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2" \
    -c:v libx264 -pix_fmt yuv420p \
    "$FIXTURES_DIR/test_video.mp4" 2>/dev/null

# Generate 1-second test audio (sine wave)
echo "Creating test_audio.wav (1 second, 440Hz sine wave)..."
ffmpeg -y -f lavfi -i "sine=frequency=440:duration=1" \
    "$FIXTURES_DIR/test_audio.wav" 2>/dev/null

# Generate test video with audio
echo "Creating test_video_with_audio.mp4 (2 seconds with audio)..."
ffmpeg -y -f lavfi -i "color=c=green:s=1280x720:d=2" \
    -f lavfi -i "sine=frequency=440:duration=2" \
    -vf "drawtext=text='TEST WITH AUDIO':fontsize=72:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2" \
    -c:v libx264 -c:a aac -pix_fmt yuv420p \
    "$FIXTURES_DIR/test_video_with_audio.mp4" 2>/dev/null

# Verify files
echo ""
echo "Generated fixtures:"
ls -lh "$FIXTURES_DIR"

echo ""
echo "Verifying files with ffprobe..."
for f in "$FIXTURES_DIR"/*; do
    echo "---"
    ffprobe -v quiet -show_format -show_streams "$f" 2>/dev/null | grep -E "^(filename|duration|width|height|codec_name)=" || true
done

echo ""
echo "Done! Test fixtures created in: $FIXTURES_DIR"
