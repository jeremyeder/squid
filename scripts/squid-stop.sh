#!/bin/bash
set -euo pipefail

echo "🦑 Stopping Squid Proxy..."

if podman container exists squid-proxy; then
    podman stop squid-proxy
    echo "✓ Squid proxy stopped"
else
    echo "✗ Container does not exist"
    exit 1
fi
