#!/bin/bash
set -euo pipefail

echo "🦑 Squid Proxy Status"
echo "===================="

# Container status
if podman container exists squid-proxy; then
    STATUS=$(podman inspect squid-proxy --format '{{.State.Status}}')
    echo "Container: $STATUS"

    if [[ "$STATUS" == "running" ]]; then
        # Test proxy
        if curl -x http://localhost:3128 -I http://example.com -s -o /dev/null -w "%{http_code}" | grep -q 200; then
            echo "Proxy: ONLINE ✓"
        else
            echo "Proxy: OFFLINE ✗"
        fi
    fi
else
    echo "Container: NOT CREATED ✗"
fi

# launchd service
if launchctl list | grep -q com.jeder.squid-proxy; then
    echo "launchd: LOADED ✓"
else
    echo "launchd: NOT LOADED ✗"
fi
