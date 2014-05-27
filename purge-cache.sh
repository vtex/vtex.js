#!/usr/bin/env bash

cd dist

for f in **/*; do
    echo "Purging cache of io.vtex.com.br/vtex.js/$f"
    curl -X DELETE "$JANUS_CACHE_MANAGER" -H "Content-Type: application/json" -d '{"path": "vtex.js/$f", "host": "54.82.11.190:8080"}'
done
