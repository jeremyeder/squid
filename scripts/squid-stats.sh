#!/bin/bash
set -euo pipefail

echo "🦑 Squid Proxy Statistics"
echo "========================="

if ! podman container exists squid-proxy; then
    echo "✗ Container does not exist. Run ./scripts/setup.sh first."
    exit 1
fi

if [[ "$(podman inspect squid-proxy --format '{{.State.Status}}')" != "running" ]]; then
    echo "✗ Container is not running. Start it with ./scripts/squid-start.sh"
    exit 1
fi

# Cache info
echo -e "\nCache Information:"
podman exec squid-proxy squidclient -h localhost mgr:info | grep -A 20 "Cache information" || echo "Cache manager not responding"

# Hit rate
echo -e "\nCache Hit Rate:"
podman exec squid-proxy squidclient -h localhost mgr:5min | grep "Request Hit Ratios" || echo "Statistics not available yet"
