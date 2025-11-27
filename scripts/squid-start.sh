#!/bin/bash
set -euo pipefail

echo "🦑 Starting Squid Proxy..."

if podman container exists squid-proxy; then
    podman start squid-proxy
    echo "✓ Squid proxy started"
else
    echo "✗ Container does not exist. Run ./scripts/setup.sh first."
    exit 1
fi
