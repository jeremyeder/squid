#!/bin/bash
set -euo pipefail

LOG_TYPE="${1:-access}"

if ! podman container exists squid-proxy; then
    echo "✗ Container does not exist. Run ./scripts/setup.sh first."
    exit 1
fi

if [[ "$(podman inspect squid-proxy --format '{{.State.Status}}')" != "running" ]]; then
    echo "✗ Container is not running. Start it with ./scripts/squid-start.sh"
    exit 1
fi

case "$LOG_TYPE" in
    access)
        podman exec squid-proxy tail -f /var/log/squid/access.log
        ;;
    cache)
        podman exec squid-proxy tail -f /var/log/squid/cache.log
        ;;
    store)
        podman exec squid-proxy tail -f /var/log/squid/store.log
        ;;
    *)
        echo "Usage: $0 {access|cache|store}"
        exit 1
        ;;
esac
