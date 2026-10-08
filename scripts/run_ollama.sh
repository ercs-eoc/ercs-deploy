#!/bin/bash

set -e

# Start Ollama server in the background.
ollama serve &
SERVER_PID=$!

echo "Waiting for Ollama server to start..."

# Wait up to 5 minutes for Ollama to become available.
MAX_RETRIES=60
RETRY=0

until ollama list >/dev/null 2>&1; do
    if ! kill -0 "$SERVER_PID" 2>/dev/null; then
        echo "ERROR: Ollama server exited during startup."
        exit 1
    fi

    RETRY=$((RETRY + 1))

    if [ "$RETRY" -ge "$MAX_RETRIES" ]; then
        echo "ERROR: Ollama failed to start within 5 minutes."
        exit 1
    fi

    sleep 5
done

echo "Ollama server is ready."

# Pull required models.
echo "Pulling model: $LLM_MODEL_NAME"
ollama pull "$LLM_MODEL_NAME"

# Pull the optional document-summary model when configured.
if [ -n "$LLM_DOC_SUMMARY_MODEL_NAME" ]; then
    echo "Pulling model: $LLM_DOC_SUMMARY_MODEL_NAME"
    ollama pull "$LLM_DOC_SUMMARY_MODEL_NAME"
fi

echo "Pulling model: $LLM_EMBEDDING_MODEL"
ollama pull "$LLM_EMBEDDING_MODEL"

echo "Models ready. Server accepting traffic."

# Keep Ollama running in the foreground.
wait "$SERVER_PID"
