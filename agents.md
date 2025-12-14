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
