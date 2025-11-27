#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WEB_DIR="$PROJECT_DIR/web"

if ! podman container exists squid-proxy; then
    echo "✗ Container does not exist. Run ./scripts/setup.sh first."
    exit 1
fi

if [[ "$(podman inspect squid-proxy --format '{{.State.Status}}')" != "running" ]]; then
    echo "✗ Container is not running. Start it with ./scripts/squid-start.sh"
    exit 1
fi

# Copy cachemgr.cgi from container if needed
if [[ ! -f "$WEB_DIR/cachemgr.cgi" ]]; then
    echo "Copying cachemgr.cgi from container..."
    podman cp squid-proxy:/usr/lib/squid/cachemgr.cgi "$WEB_DIR/"
    chmod +x "$WEB_DIR/cachemgr.cgi"
fi

echo "🌐 Starting cache manager server..."
echo "   URL: http://localhost:8080/cachemgr.cgi"
echo "   Password: secretpassword"
echo ""
echo "   Press Ctrl+C to stop"

cd "$WEB_DIR"
python3 -m http.server 8080 --cgi
