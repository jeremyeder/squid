#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🦑 Squid Proxy Setup"
echo "===================="

# 1. Build custom Squid image
echo -e "\n[1/5] Building custom Squid image..."
podman build -t localhost/squid:latest "$PROJECT_DIR"

# 2. Create named volumes
echo -e "\n[2/5] Creating named volumes..."
podman volume create squid-cache 2>/dev/null || echo "✓ squid-cache volume exists"
podman volume create squid-logs 2>/dev/null || echo "✓ squid-logs volume exists"

# 3. Create container
echo -e "\n[3/5] Creating Squid container..."
if podman container exists squid-proxy; then
    echo "✓ Container already exists"
else
    podman create \
        --name squid-proxy \
        --restart always \
        -p 127.0.0.1:3128:3128 \
        -v "$PROJECT_DIR/config/squid.conf:/etc/squid/squid.conf:ro,Z" \
        -v squid-cache:/var/spool/squid:Z \
        -v squid-logs:/var/log/squid:Z \
        localhost/squid:latest
    echo "✓ Container created"
fi

# 4. Start container (cache initialization happens in entrypoint)
echo -e "\n[4/5] Starting Squid container..."
podman start squid-proxy
echo "✓ Container started"

# 5. Install launchd service
echo -e "\n[5/5] Installing launchd service..."
LAUNCHD_PLIST="$HOME/Library/LaunchAgents/com.jeder.squid-proxy.plist"
cp "$PROJECT_DIR/launchd/com.jeder.squid-proxy.plist" "$LAUNCHD_PLIST"
launchctl unload "$LAUNCHD_PLIST" 2>/dev/null || true
launchctl load "$LAUNCHD_PLIST"
echo "✓ launchd service installed"

echo -e "\n✅ Setup complete!"
echo -e "\nNext steps:"
echo "  1. Add to shell profile (~/.zshrc):"
echo "       export http_proxy=http://localhost:3128"
echo "       export https_proxy=http://localhost:3128"
echo "  2. Test: curl -x http://localhost:3128 -I https://www.redhat.com"
echo "  3. Check status: ./scripts/squid-status.sh"
echo "  4. View stats: ./scripts/squid-stats.sh"
