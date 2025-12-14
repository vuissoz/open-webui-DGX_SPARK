# Agents & Usage

## Ollama
- **Container:** `ollama`
- **Purpose:** Hosts the Ollama runtime that serves models to Open WebUI.
- **Useful commands:**
  ```bash
  docker exec -it ollama ollama list
  docker exec -it ollama ollama pull llama3
  docker exec -it ollama ollama rm llama3
  docker exec -it ollama /bin/sh
  ```
- **Data path:** `ollama_data/` (mounted to `/root/.ollama` for model blobs and cache files).
- **GPU visibility:** `docker-compose.yml` injects `CUDA_VISIBLE_DEVICES`/`NVIDIA_VISIBLE_DEVICES`. Override them before running `docker compose up` if you need a specific GPU, and confirm CUDA is active via `docker compose logs ollama | grep ggml_cuda_init` (more reliable than `nvidia-smi` on DGX/Grace systems).

## Open WebUI
- **Container:** `open-webui`
- **Purpose:** Front-end/UI layer that connects users to Ollama models.
- **Useful commands:**
  ```bash
  docker exec -it open-webui /bin/sh
  docker compose logs -f open-webui
  ```
- **Data path:** `openwebui_data/` plus `data/` for backend state and configuration.

## Helper Scripts
- `scripts/list_ollama_models_by_size.sh` lists all models known to the Ollama container and sorts them from largest to smallest to help manage disk usage.
- `scripts/remove_ollama_model.sh <model-name> [container-name]` removes a model via `ollama rm` without needing to enter the container manually.

## Stack Lifecycle
Use these commands from the repo root:
```bash
docker compose down
docker compose pull
docker compose up -d --force-recreate
```
The sequence stops the services, downloads the newest images, and recreates containers so updated GPU environment variables take effect.
