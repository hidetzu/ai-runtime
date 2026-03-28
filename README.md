# ai-runtime

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Docker Compose](https://img.shields.io/badge/Docker_Compose-v2-blue.svg)](https://docs.docker.com/compose/)
[![NVIDIA GPU](https://img.shields.io/badge/NVIDIA-GPU_Required-green.svg)](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

Shared AI runtime infrastructure for local GPU environments. Manages common AI services via Docker Compose for prototype development.

## Services

| Service | Profile | Host Port | Description |
|---------|---------|-----------|-------------|
| Ollama | `llm` | 11434 | LLM inference server |
| Whisper | `whisper` | 8100 | Speech-to-text (faster-whisper-server) |

## Prerequisites

- Docker with [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
- NVIDIA GPU
- [jq](https://jqlang.github.io/jq/) (used by setup scripts)

## Quick Start

```bash
cp .env.example .env

# Start all services
docker compose --profile llm --profile whisper up -d

# Start LLM only
docker compose --profile llm up -d

# Pull a model into Ollama
docker compose exec ollama ollama pull llama3
```

## Connecting from Your App

### Via Docker network

Join the `ai-runtime` network from your app's `compose.yaml`:

```yaml
services:
  app:
    # ...
    networks:
      - ai-runtime

networks:
  ai-runtime:
    external: true
```

Access services by name:
- Ollama: `http://ollama:11434`
- Whisper: `http://whisper:8000`

### Via host port forwarding

- Ollama: `http://localhost:11434`
- Whisper: `http://localhost:8100`

## Configuration

Override ports and model settings in `.env`. See `.env.example` for defaults.
