#!/bin/bash
set -euo pipefail

echo "🗑️  Clearing Squid cache..."

if ! podman container exists squid-proxy; then
    echo "✗ Container does not exist. Run ./scripts/setup.sh first."
    exit 1
fi

podman stop squid-proxy
podman volume rm squid-cache squid-logs
podman volume create squid-cache
podman volume create squid-logs
podman start squid-proxy
sleep 2
podman exec squid-proxy squid -z

echo "✓ Cache cleared and reinitialized"
