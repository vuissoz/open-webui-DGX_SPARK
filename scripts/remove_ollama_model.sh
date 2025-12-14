#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <model-name> [container-name]" >&2
  exit 1
fi

MODEL_NAME=$1
CONTAINER_NAME=${2:-ollama}

if ! docker ps --format '{{.Names}}' | grep -Fxq "$CONTAINER_NAME"; then
  echo "Container '$CONTAINER_NAME' is not running." >&2
  exit 1
fi

echo "Removing model '$MODEL_NAME' from container '$CONTAINER_NAME'..."
docker exec "$CONTAINER_NAME" ollama rm "$MODEL_NAME"

echo "Model '$MODEL_NAME' removed."
