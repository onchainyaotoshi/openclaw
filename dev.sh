#!/usr/bin/env bash
set -euo pipefail

# Hard isolate DEV env
export OPENCLAW_HOME="/root/.openclaw-dev"
export OPENCLAW_STATE_DIR="/root/.openclaw-dev"
export OPENCLAW_CONFIG_PATH="/root/.openclaw-dev/openclaw.json"
export OPENCLAW_GATEWAY_PORT="19001"

# Optional: safety info
echo "[dev-wa] OPENCLAW_HOME=$OPENCLAW_HOME"
echo "[dev-wa] OPENCLAW_CONFIG_PATH=$OPENCLAW_CONFIG_PATH"
echo "[dev-wa] PORT=$OPENCLAW_GATEWAY_PORT"

# Kill old dev process only (safe)
pkill -f "openclaw.*19001" || true

# Run gateway dev with WhatsApp enabled (NO skip channels)
exec openclaw gateway run --port 19001
