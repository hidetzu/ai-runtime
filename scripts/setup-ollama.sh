#!/usr/bin/env bash
set -euo pipefail

# Ollama model setup script
# Download models to a local or remote Ollama instance

OLLAMA_URL="${AI_RUNTIME_OLLAMA_URL:-http://localhost:11434}"
DEFAULT_MODEL="gemma3:4b"
MODELS=("gemma3:4b" "gemma3:12b")

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] [MODEL]

Download a model to Ollama.

Arguments:
  MODEL    Model name to download (default: ${DEFAULT_MODEL})

Options:
  -a, --all        Download all predefined models (${MODELS[*]})
  -u, --url URL    Ollama URL (default: ${OLLAMA_URL})
                   Can also be set via AI_RUNTIME_OLLAMA_URL
  -l, --list       List downloaded models
  -h, --help       Show this help

Examples:
  $(basename "$0")                              # Download the default model
  $(basename "$0") gemma3:12b                   # Download a specific model
  $(basename "$0") --all                        # Download all predefined models
  $(basename "$0") -u http://192.168.1.10:11434 # Connect to a remote Ollama
  $(basename "$0") --list                       # List models
EOF
}

list_models() {
  echo "Ollama URL: ${OLLAMA_URL}"
  echo "Downloaded models:"
  curl -sf "${OLLAMA_URL}/api/tags" | jq . || {
    echo "Error: cannot connect to Ollama (${OLLAMA_URL})"
    exit 1
  }
}

pull_model() {
  local model="$1"
  echo "Ollama URL: ${OLLAMA_URL}"
  echo "Pulling model: ${model}"
  if ! curl -sf "${OLLAMA_URL}/api/pull" -d "{\"name\": \"${model}\"}" | while IFS= read -r line; do
    error=$(echo "${line}" | jq -r '.error // empty')
    if [ -n "${error}" ]; then
      echo "Error: ${error}"
      exit 1
    fi
    status=$(echo "${line}" | jq -r '.status // empty')
    if [ -n "${status}" ]; then
      echo "  ${status}"
    fi
  done; then
    echo "Error: failed to pull model '${model}'"
    exit 1
  fi

  echo "Done: ${model}"
}

check_ollama() {
  if ! curl -sf "${OLLAMA_URL}/api/tags" > /dev/null 2>&1; then
    echo "Error: cannot connect to Ollama (${OLLAMA_URL})"
    echo ""
    echo "Please check the following:"
    echo "  1. Start the Ollama container: docker compose --profile llm up -d"
    echo "  2. Or specify a remote Ollama URL:"
    echo "     export AI_RUNTIME_OLLAMA_URL=http://<host>:11434"
    exit 1
  fi
}

# Parse arguments
MODEL="${DEFAULT_MODEL}"
LIST=false
ALL=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -u|--url)
      OLLAMA_URL="$2"
      shift 2
      ;;
    -a|--all)
      ALL=true
      shift
      ;;
    -l|--list)
      LIST=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
    *)
      MODEL="$1"
      shift
      ;;
  esac
done

check_ollama

if [ "${LIST}" = true ]; then
  list_models
elif [ "${ALL}" = true ]; then
  for model in "${MODELS[@]}"; do
    pull_model "${model}"
  done
else
  pull_model "${MODEL}"
fi
