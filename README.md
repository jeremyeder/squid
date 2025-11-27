# Squid Caching Proxy for Claude Code

Local caching proxy to speed up Claude Code sessions by caching web content.

## Features

- 10GB disk cache for web content
- HTTPS support via SSL bumping
- Auto-start on boot (launchd)
- CLI management scripts
- Web-based cache manager
- Balanced caching strategy (respects TTLs)

## Quickstart

```bash
# Initial setup
./scripts/setup.sh

# Configure shell (add to ~/.zshrc)
export http_proxy=http://localhost:3128
export https_proxy=http://localhost:3128

# Test
curl -x http://localhost:3128 -I https://www.redhat.com
```

## Management

```bash
# Status and stats
./scripts/squid-status.sh
./scripts/squid-stats.sh

# Control
./scripts/squid-start.sh
./scripts/squid-stop.sh

# Logs
./scripts/squid-logs.sh access  # or cache, store

# Maintenance
./scripts/squid-clear-cache.sh

# Web UI
./scripts/cachemgr-server.sh
open http://localhost:8080/cachemgr.cgi
```

## Testing Cache Effectiveness

```bash
# First request (cache MISS)
time curl -x http://localhost:3128 -I https://www.redhat.com

# Second request (cache HIT - should be 10x faster!)
time curl -x http://localhost:3128 -I https://www.redhat.com

# View statistics
./scripts/squid-stats.sh
```

## Troubleshooting

**SSL certificate errors:**
```bash
# Verify cert is trusted
security find-certificate -c "Squid Proxy CA" /Library/Keychains/System.keychain

# Reinstall if needed
sudo security add-trusted-cert -d -r trustRoot \
    -k /Library/Keychains/System.keychain \
    certs/squid-ca.pem
```

**Proxy not working:**
```bash
# Check container
podman ps -a | grep squid-proxy

# Check logs
./scripts/squid-logs.sh cache

# Restart
podman restart squid-proxy
```

## Uninstall

```bash
# Stop and remove
podman stop squid-proxy && podman rm squid-proxy
podman volume rm squid-cache squid-logs

# Remove launchd service
launchctl unload ~/Library/LaunchAgents/com.jeder.squid-proxy.plist
rm ~/Library/LaunchAgents/com.jeder.squid-proxy.plist

# Remove certificate
sudo security delete-certificate -c "Squid Proxy CA" \
    /Library/Keychains/System.keychain
```
