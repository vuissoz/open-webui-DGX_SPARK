#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME=${1:-ollama}

if ! docker ps --format '{{.Names}}' | grep -Fxq "$CONTAINER_NAME"; then
  echo "Container '$CONTAINER_NAME' is not running." >&2
  exit 1
fi

list_output=$(docker exec "$CONTAINER_NAME" ollama list)
if [[ -z "$list_output" ]]; then
  echo "No output from 'ollama list'." >&2
  exit 1
fi

printf '%s\n' "$list_output" | {
  read -r header || exit 0
  printf '%s\n' "$header"
  awk '
    function to_bytes(size_str,   matches, value, unit) {
      if (match(size_str, /^([0-9.]+)([KMGTP]?B)$/ , matches)) {
        value = matches[1] + 0
        unit = matches[2]
      } else {
        value = size_str + 0
        unit = "B"
      }
      if (unit == "B") return value
      else if (unit == "KB") return value * 1024
      else if (unit == "MB") return value * 1024 * 1024
      else if (unit == "GB") return value * 1024 * 1024 * 1024
      else if (unit == "TB") return value * 1024 * 1024 * 1024 * 1024
      else if (unit == "PB") return value * 1024 * 1024 * 1024 * 1024 * 1024
      return value
    }
    {
      size_str = $3 $4   # joins number and unit (e.g., "815MB", "42GB")
      bytes = to_bytes(size_str)
      printf "%020.0f\t%s\n", bytes, $0
    }
  ' | sort -r -k1,1 | cut -f2-
}
