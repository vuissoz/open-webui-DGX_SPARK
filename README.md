# Open WebUI + Ollama Stack

Docker Compose bundle that provisions an Ollama runtime alongside Open WebUI, with the model state and UI data persisted on the host for easy backups and upgrades.

## Prerequisites
- Docker Engine 24+ with the Compose plugin
- GPU drivers/runtime that match the `ollama/ollama:latest` image if you plan to use GPU acceleration
- A `.env` file (already tracked here) that exposes `WEBUI_PORT`, `OLLAMA_PORT`, and `OLLAMA_BASE_URL`

## Getting Started
1. Review `.env` and adjust the published ports or base URL if needed.
2. Start the stack:
   ```bash
   docker compose up -d
   ```
3. Visit Open WebUI at `http://localhost:${WEBUI_PORT}` (default `8080`). It is already configured to send traffic to the Ollama service at `http://ollama:11434`.
4. Tail logs when needed:
   ```bash
   docker compose logs -f open-webui
   docker compose logs -f ollama
   ```
5. Stop everything:
   ```bash
   docker compose down
   ```
6. **GPU users:** Inspect the Ollama logs for the line `ggml_cuda_init: found` to confirm CUDA is active. On DGX/Grace systems `nvidia-smi` often fails even though CUDA works, so the logs are the source of truth.

### GPU configuration
- `docker-compose.yml` sets `CUDA_VISIBLE_DEVICES`, `NVIDIA_VISIBLE_DEVICES`, and `NVIDIA_DRIVER_CAPABILITIES` for the `ollama` service. Override them in your shell when you need to target a specific device:
  ```bash
  export CUDA_VISIBLE_DEVICES=1
  docker compose up -d
  ```
- If the host wipes `CUDA_VISIBLE_DEVICES`, Ollama falls back to CPU. `docker compose logs ollama | grep ggml_cuda_init` quickly shows whether GPUs are still visible.

## Managing Ollama Models
- Run the Ollama CLI inside the container named `ollama`:
  ```bash
  docker exec -it ollama ollama list
  docker exec -it ollama ollama pull llama3
  docker exec -it ollama ollama rm llama3
  docker exec -it ollama /bin/sh   # optional shell access
  ```
- Quickly inspect models ordered by on-disk size (largest first) with the helper script:
  ```bash
  ./scripts/list_ollama_models_by_size.sh          # uses container "ollama"
  ./scripts/list_ollama_models_by_size.sh custom   # pass a different container name
  ```
  The script runs `ollama list`, converts each size into bytes for accurate sorting, and prints the header plus rows from biggest to smallest.
- Delete a specific model by name (wraps `ollama rm` and still works even if the CLI isn’t in your PATH):
  ```bash
  ./scripts/remove_ollama_model.sh llama3          # remove from container "ollama"
  ./scripts/remove_ollama_model.sh llama3 custom   # target another container
  ```

## Data Persistence
- `ollama_data/` → mounted to `/root/.ollama` inside the container where model weights and caches live.
- `openwebui_data/` → mounted to `/app/backend/data` to store application metadata.
- `data/` → additional backend data directory exposed to Open WebUI.

Back up these folders before upgrading images or pruning containers.

## Updating
Perform a clean restart so new environment variables are applied:
```bash
docker compose down
docker compose pull
docker compose up -d --force-recreate
```

## Troubleshooting
- **Container not running:** `docker compose ps` to verify, then `docker compose up -d`.
- **Port already in use:** modify `WEBUI_PORT` or `OLLAMA_PORT` in `.env` and restart.
- **Missing models:** rerun `ollama pull <model>` inside the container or restore the `ollama_data/` folder from backup.
