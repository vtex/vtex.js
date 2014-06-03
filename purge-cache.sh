#!/usr/bin/env bash

echo "Purging cache of io.vtex.com.br/vtex.js/*"
curl -sS -X DELETE "$JANUS_CACHE_MANAGER"
