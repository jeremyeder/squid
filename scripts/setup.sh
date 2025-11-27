#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🦑 Squid Proxy Setup"
echo "===================="

# 1. Generate SSL certificates
echo -e "\n[1/7] Generating SSL certificates..."
if [[ ! -f "$PROJECT_DIR/certs/squid-ca.pem" ]]; then
    "$SCRIPT_DIR/gen-certs.sh"
else
    echo "✓ Certificates already exist"
fi

# 2. Install CA certificate in macOS keychain
echo -e "\n[2/7] Installing CA certificate in macOS keychain..."
if ! security find-certificate -c "Squid Proxy CA" /Library/Keychains/System.keychain &>/dev/null; then
    sudo security add-trusted-cert -d -r trustRoot \
        -k /Library/Keychains/System.keychain \
        "$PROJECT_DIR/certs/squid-ca.pem"
    echo "✓ CA certificate installed (requires sudo)"
else
    echo "✓ CA certificate already installed"
fi

# 3. Pull Squid image
echo -e "\n[3/7] Pulling Ubuntu Squid image..."
podman pull docker.io/ubuntu/squid:latest

# 4. Create named volumes
echo -e "\n[4/7] Creating named volumes..."
podman volume create squid-cache 2>/dev/null || echo "✓ squid-cache volume exists"
podman volume create squid-logs 2>/dev/null || echo "✓ squid-logs volume exists"

# 5. Create container
echo -e "\n[5/7] Creating Squid container..."
if podman container exists squid-proxy; then
    echo "✓ Container already exists"
else
    podman create \
        --name squid-proxy \
        --restart always \
        -p 127.0.0.1:3128:3128 \
        -v "$PROJECT_DIR/config/squid.conf:/etc/squid/squid.conf:ro,Z" \
        -v "$PROJECT_DIR/certs:/etc/squid/certs:ro,Z" \
        -v squid-cache:/var/spool/squid:Z \
        -v squid-logs:/var/log/squid:Z \
        docker.io/ubuntu/squid:latest
    echo "✓ Container created"
fi

# 6. Initialize cache
echo -e "\n[6/7] Initializing cache directories..."
podman start squid-proxy
sleep 2
podman exec squid-proxy squid -z || echo "✓ Cache already initialized"

# 7. Install launchd service
echo -e "\n[7/7] Installing launchd service..."
LAUNCHD_PLIST="$HOME/Library/LaunchAgents/com.jeder.squid-proxy.plist"
cp "$PROJECT_DIR/launchd/com.jeder.squid-proxy.plist" "$LAUNCHD_PLIST"
launchctl unload "$LAUNCHD_PLIST" 2>/dev/null || true
launchctl load "$LAUNCHD_PLIST"
echo "✓ launchd service installed"

# Start proxy
echo -e "\n✅ Setup complete!"
echo -e "\nNext steps:"
echo "  1. Add to shell profile (~/.zshrc):"
echo "       export http_proxy=http://localhost:3128"
echo "       export https_proxy=http://localhost:3128"
echo "  2. Test: curl -x http://localhost:3128 -I https://www.redhat.com"
echo "  3. Check status: ./scripts/squid-status.sh"
echo "  4. View stats: ./scripts/squid-stats.sh"
